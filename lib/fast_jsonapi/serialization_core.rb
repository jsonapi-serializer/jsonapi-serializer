# frozen_string_literal: true

require 'active_support/concern'
require 'digest/sha1'
require 'batch-loader'

module FastJsonapi
  MandatoryField = Class.new(StandardError)

  module SerializationCore
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :attributes_to_serialize,
                      :relationships_to_serialize,
                      :cachable_relationships_to_serialize,
                      :uncachable_relationships_to_serialize,
                      :transform_method,
                      :record_type,
                      :record_id,
                      :cache_store_instance,
                      :cache_store_options,
                      :data_links,
                      :meta_to_serialize
      end
    end

    class_methods do
      def id_hash(id, record_type, default_return = false)
        if id.present?
          { id: id.to_s, type: record_type }
        else
          default_return ? { id: nil, type: record_type } : nil
        end
      end

      def links_hash(record, params = {})
        data_links.each_with_object({}) do |(_k, link), hash|
          link.serialize(record, params, hash)
        end
      end

      def attributes_hash(record, fieldset = nil, params = {})
        attributes = attributes_to_serialize
        attributes = attributes.slice(*fieldset) if fieldset.present?
        attributes = {} if fieldset == []

        attributes.each_with_object({}) do |(_k, attribute), hash|
          attribute.serialize(record, params, hash)
        end
      end

      def relationships_hash(record, relationships = nil, fieldset = nil, includes_list = nil, params = {})
        relationships = relationships_to_serialize if relationships.nil?
        relationships = relationships.slice(*fieldset) if fieldset.present?
        relationships = {} if fieldset == []

        relationships.each_with_object({}) do |(key, relationship), hash|
          included = includes_list.present? && includes_list.include?(key)
          relationship.serialize(record, included, params, hash)
        end
      end

      def meta_hash(record, params = {})
        FastJsonapi.call_proc(meta_to_serialize, record, params)
      end

      # Move the namespace to be part of cache_key
      # since ActiveSupport doesn't support multi read with different namespaces
      #
      # Use #cache_key_with_version instead of #cache_key because we don't
      # pass AR objects as keys to cache store and thus we can't leverage the
      # built-in cache versioning from rails 6. This is a good opportunity for
      # future improvement.
      def generate_cache_key(record, namespace)
        "#{namespace}-#{record.cache_key_with_version}"
      end

      def record_hash(record, fieldset, includes_list, params = {})
        if cache_store_instance
          cache_opts = record_cache_options(record, cache_store_options, fieldset, includes_list, params)
          name_space = cache_opts.delete(:namespace)
          cache_key = generate_cache_key(record, name_space)
          fetch_query = {
            cache_key: cache_key,
            cache_opts: cache_opts,
            record: record,
            klass: self,
            params: params
          }
          Thread.current[:jsonapi_serializer] ||= {}
          Thread.current[:jsonapi_serializer][cache_key] = fetch_query

          BatchLoader.for(cache_key).batch(replace_methods: false) do |cache_keys, loader|
            # load the fetch_queries(batch_params) from thread local variable
            # because the batchloader use batch item(cache_key in this case) as a hash key
            # which will cause performance issue when batch item getting huge
            batch_params = Thread.current[:jsonapi_serializer].fetch_values(*cache_keys)
            # load the cached value from cache store
            cache_hits = cache_store_instance.read_multi(*cache_keys)

            # for not cached record, group it by cache options
            # {
            #   { ...cache_option } => [
            #     { "cache_key_1" => { ...record_hash_1 } },
            #     { "cache_key_2" => { ...record_hash_2 } },
            #     ...
            #   ],
            #   .... # different cache options
            # }
            uncached_by_opts = batch_params
              .reject { |h| cache_hits[h[:cache_key]] }
              .group_by { |h| h[:cache_opts] }

            uncached_by_opts.transform_values! do |arr|
              arr.each_with_object({}) do |b_param, record_hashes_by_cache_key|
                record_hash = b_param[:klass].id_hash(b_param[:klass].id_from_record(b_param[:record], b_param[:params]), b_param[:klass].record_type, true)
                record_hash[:attributes] = b_param[:klass].attributes_hash(b_param[:record], fieldset, b_param[:params]) if b_param[:klass].attributes_to_serialize.present?
                record_hash[:relationships] = b_param[:klass].relationships_hash(b_param[:record], nil, fieldset, includes_list, b_param[:params]) if b_param[:klass].relationships_to_serialize.present?
                record_hash[:links] = b_param[:klass].links_hash(b_param[:record], b_param[:params]) if b_param[:klass].data_links.present?
                record_hashes_by_cache_key[b_param[:cache_key]] = record_hash
              end
            end

            # cache the uncached record
            uncached_by_opts.each do |cache_options, record_hashes_by_cache_key|
              # manually sync the record hashes in case record having batch loaded attributes
              # which is not compatiable with rails native cache store Marshal serialization
              cache_store_instance.write_multi(deep_sync(record_hashes_by_cache_key), cache_options)
            end

            record_hashes_by_cache_key = nil
            # gathering all cache_key => record_hash pairs
            record_hashes_by_cache_key = uncached_by_opts.values.reduce({}, :merge!).merge!(cache_hits)

            # push all record_hash to batch loader context
            batch_params.each do |b_param|
              record_hash = record_hashes_by_cache_key[b_param[:cache_key]]
              # evaluate live meta attribute since it's time sensitive
              record_hash[:meta] = b_param[:klass].meta_hash(b_param[:record], b_param[:params]) if b_param[:klass].meta_to_serialize.present?
              loader.call(b_param[:cache_key], record_hash)
            end
          end
        else
          record_hash = id_hash(id_from_record(record, params), record_type, true)
          record_hash[:attributes] = attributes_hash(record, fieldset, params) if attributes_to_serialize.present?
          record_hash[:relationships] = relationships_hash(record, nil, fieldset, includes_list, params) if relationships_to_serialize.present?
          record_hash[:links] = links_hash(record, params) if data_links.present?
          record_hash[:meta] = meta_hash(record, params) if meta_to_serialize.present?
          record_hash
        end
      end

      # manually sync the nested batchloader instances
      def deep_sync(collection)
        if collection.is_a? Hash
          collection.each_with_object({}) do |(k, v), hsh|
            hsh[k] = deep_sync(v)
          end
        elsif collection.is_a? Array
          collection.map { |i| deep_sync(i) }
        else
          collection.respond_to?(:__sync) ? collection.__sync : collection
        end
      end

      # Cache options helper. Use it to adapt cache keys/rules.
      #
      # If a fieldset is specified, it modifies the namespace to include the
      # fields from the fieldset.
      #
      # Allow namespace passed in a proc to
      # generate unique key base on serializer dynamic params
      #
      # @param options [Hash] default cache options
      # @param fieldset [Array, nil] passed fieldset values
      # @param includes_list [Array, nil] passed included values
      # @param params [Hash] the serializer params
      #
      # @return [Hash] processed options hash
      # rubocop:disable Lint/UnusedMethodArgument
      def record_cache_options(record, options, fieldset, includes_list, params)
        options = options ? options.dup : {}

        if options[:namespace].is_a?(Proc)
          options[:namespace] = FastJsonapi.call_proc(options[:namespace], record, params)
        end

        options[:namespace] = "j16r-#{options[:namespace]}" unless options[:namespace]&.start_with?('j16r-')
        options

        # temp disable fieldset support to minimum change scope
        # TODO: add fieldset support back and verify behavior
        # return options unless fieldset

        # fieldset_key = fieldset.join('_')

        # # Use a fixed-length fieldset key if the current length is more than
        # # the length of a SHA1 digest
        # if fieldset_key.length > 40
        #   fieldset_key = Digest::SHA1.hexdigest(fieldset_key)
        # end

        # options[:namespace] = "#{options[:namespace]}-fieldset:#{fieldset_key}"
        # options
      end
      # rubocop:enable Lint/UnusedMethodArgument

      def id_from_record(record, params)
        return FastJsonapi.call_proc(record_id, record, params) if record_id.is_a?(Proc)
        return record.send(record_id) if record_id
        raise MandatoryField, 'id is a mandatory field in the jsonapi spec' unless record.respond_to?(:id)

        record.id
      end

      # It chops out the root association (first part) from each include.
      #
      # It keeps an unique list and collects all of the rest of the include
      # value to hand it off to the next related to include serializer.
      #
      # This method will turn that include array into a Hash that looks like:
      #
      #   {
      #       authors: Set.new([
      #         'books',
      #         'books.genre',
      #         'books.genre.books',
      #         'books.genre.books.authors',
      #         'books.genre.books.genre'
      #       ]),
      #       genre: Set.new(['books'])
      #   }
      #
      # Because the serializer only cares about the root associations
      # included, it only needs the first segment of each include
      # (for books, it's the "authors" and "genre") and it doesn't need to
      # waste cycles parsing the rest of the include value. That will be done
      # by the next serializer in line.
      #
      # @param includes_list [List] to be parsed
      # @return [Hash]
      def parse_includes_list(includes_list)
        includes_list.each_with_object({}) do |include_item, include_sets|
          include_base, include_remainder = include_item.to_s.split('.', 2)
          include_sets[include_base.to_sym] ||= Set.new
          include_sets[include_base.to_sym] << include_remainder if include_remainder
        end
      end

      # includes handler
      def get_included_records(record, includes_list, known_included_objects, fieldsets, params = {})
        return unless includes_list.present?
        return [] unless relationships_to_serialize

        includes_list = parse_includes_list(includes_list)

        includes_list.each_with_object([]) do |include_item, included_records|
          relationship_item = relationships_to_serialize[include_item.first]

          next unless relationship_item&.include_relationship?(record, params)

          included_objects = Array(relationship_item.fetch_associated_object(record, params))
          next if included_objects.empty?

          static_serializer = relationship_item.static_serializer
          static_record_type = relationship_item.static_record_type

          included_objects.each do |inc_obj|
            serializer = static_serializer || relationship_item.serializer_for(inc_obj, params)
            record_type = static_record_type || serializer.record_type

            if include_item.last.any?
              serializer_records = serializer.get_included_records(inc_obj, include_item.last, known_included_objects, fieldsets, params)
              included_records.concat(serializer_records) unless serializer_records.empty?
            end

            code = "#{record_type}_#{serializer.id_from_record(inc_obj, params)}"
            next if known_included_objects.include?(code)

            known_included_objects << code

            included_records << serializer.record_hash(inc_obj, fieldsets[record_type], includes_list, params)
          end
        end
      end
    end
  end
end
