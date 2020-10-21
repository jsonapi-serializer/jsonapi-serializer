# frozen_string_literal: true

# rubocop:disable Lint/DuplicateRescueException
begin
  require 'active_support/inflector'
rescue LoadError
  require 'dry/inflector'
rescue LoadError
  warn(
    'No inflector found. Install `dry-inflector` or `active_support/inflector`'
  )
end
# rubocop:enable Lint/DuplicateRescueException

module JSONAPI
  module Serializer
    # Our serializer DSL
    module DSL
      attr_writer :record_type, :record_id
      attr_accessor(
        :transform_method,
        :attributes_to_serialize,
        :relationships_to_serialize,
        :data_links,
        :meta_to_serialize,
        :cache_store_instance,
        :cache_store_options
      )

      def inherited(subclass)
        super

        subclass.attributes_to_serialize = attributes_to_serialize.dup
        subclass.relationships_to_serialize = relationships_to_serialize.dup
        subclass.transform_method = transform_method
        subclass.data_links = data_links.dup
        subclass.cache_store_instance = cache_store_instance
        subclass.cache_store_options = cache_store_options
        subclass.meta_to_serialize = meta_to_serialize
        subclass.record_id = record_id

        ::JSONAPI::Serializer.register_serializer(subclass)
      end

      def set_key_transform(transform_name)
        @transform_method = TRANSFORMS_MAPPING[transform_name.to_sym]
      end

      def set_type(type_name)
        @record_type = type_name
      end

      def record_type
        @record_type ||= run_key_transform(
          name.chomp('Serializer'),
          [:demodulize, :underscore]
        )

        run_key_transform(@record_type)
      end

      def set_id(id_name = nil, &block)
        @record_id = block || id_name
      end

      def record_id
        @record_id || :id
      end

      def attributes(*attributes_list, **options, &block)
        @attributes_to_serialize ||= {}

        attributes_list.each do |attr_name|
          @attributes_to_serialize[attr_name] = {
            key: attr_name,
            method: block || attr_name,
            options: options.freeze
          }.freeze
        end
      end
      alias attribute attributes

      def belongs_to(relationship_name, options = {}, &block)
        @relationships_to_serialize ||= {}

        @relationships_to_serialize[relationship_name] = {
          name: relationship_name,
          relationship_type: __callee__,
          options: options,
          object_block: block
        }

        # Run the resolver...
        ::JSONAPI::Serializer
          .serializers.map(&:resolve_relationship_serializers!)
      end
      alias has_one belongs_to
      alias has_many belongs_to

      def meta(meta_name = nil, &block)
        @meta_to_serialize = meta_name || block
      end

      def link(link_name, link_method_name = nil, **options, &block)
        @data_links ||= {}

        @data_links[link_name] = {
          key: link_name,
          method: link_method_name || block,
          options: options.freeze
        }.freeze
      end

      def cache_options(cache_options)
        @cache_store_instance = cache_options[:store]
        @cache_store_options = cache_options.except(:store).freeze
      end

      def resolve_relationship_serializers!
        return if @relationships_to_serialize.nil?

        @relationships_to_serialize.each do |_rel_name, relationship|
          next if relationship.frozen?

          resolve_relationship_serializer(relationship)
        end
      rescue NotFoundError
        # Ignore it, probably not all serializers are defined...
      end

      def run_key_transform(key, transform_methods = nil)
        return key.to_sym if inflector.nil?

        tmethods = @transform_method || transform_methods

        return key.to_sym if tmethods.nil?

        Array(tmethods).each do |tmethod|
          key = inflector.send(tmethod, key.to_s)
        end

        key.to_sym
      end

      private

      # Maps tranformations to inflector methods
      TRANSFORMS_MAPPING = {
        camel: :camelize,
        camel_lower: [:camelize, :lower],
        dash: :dasherize,
        underscore: :underscore
      }.freeze

      # Resolves serializer options of relationship into proper classe(s)
      #
      # We skip classes and procs since those suggest per record serializer
      # classes. On no options available, the name of the relationship is used
      # to reflect on the serializer class.
      #
      # @params relationship [Hash] the relationship data
      # @return nil
      def resolve_relationship_serializer(relationship)
        opts = relationship[:options]

        # The two are exclusive...
        return opts.delete(:serializer) unless opts[:serializers].nil?

        sname = opts[:serializer] || relationship[:name].to_s

        return if sname.is_a?(Class) || sname.is_a?(Proc)

        singularize = relationship[:relationship_type] == :has_many

        sname = inflector.singularize(sname) if inflector && singularize

        opts[:serializer] = ::JSONAPI::Serializer.for_type(sname)

        opts.freeze && relationship.freeze
      end

      # Helper method to pick an available inflector implementation
      #
      # @return [Object]
      def inflector
        ActiveSupport::Inflector
      rescue NameError
        Dry::Inflector.new
      end
    end
  end
end
