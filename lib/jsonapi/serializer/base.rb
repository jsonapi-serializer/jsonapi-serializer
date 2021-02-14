# frozen_string_literal: true

module JSONAPI
  module Serializer
    # Our serializer PORO functionality
    module Base
      def initialize(resource, opts = {})
        @resource = resource
        @options = opts.dup
        @params = @options.delete(:params) || {}
        @fieldsets = @options.delete(:fields) || {}
        @includes = @options.delete(:include) || []
        @include = @includes.map(&:to_s).map(&:strip).reject(&:empty?)
      end

      def serializable_hash
        is_collection = ::JSONAPI::Serializer.collection?(
          @resource, force: @options[:is_collection]
        )

        jsonapi = { data: nil }
        jsonapi[:data] = [] if is_collection
        jsonapi[:meta] = @options[:meta] if @options[:meta].is_a?(Hash)
        jsonapi[:links] = @options[:links] if @options[:links].is_a?(Hash)

        return jsonapi if @resource.nil? || (is_collection && @resource.empty?)

        data = []
        included = []

        # Used to avoid including duplicate records...
        included_oids = Set.new

        Array(@resource).each do |record|
          serializer_class = self.class unless is_collection
          serializer_class ||= JSONAPI::Serializer.for_object(record)

          fieldset = @fieldsets[serializer_class.record_type]
          data << serializer_class.record_hash(record, fieldset, @params)

          included += serializer_class.record_includes(
            record, @includes, included_oids, @fieldsets, @params
          )
        end

        jsonapi[:data] = data
        jsonapi[:data] = data.first unless is_collection
        jsonapi[:included] = included unless @includes.empty?
        jsonapi
      end
    end
  end
end
