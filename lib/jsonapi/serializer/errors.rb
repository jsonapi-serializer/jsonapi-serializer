# frozen_string_literal: true

module JSONAPI
  module Serializer
    # Generic error class
    class Error < StandardError; end

    # Used to indicate that a resource `id` is missing
    class IdError < StandardError
      def message
        'Resource ID is missing, see: '\
        'https://jsonapi.org/format/#document-resource-object-identification'
      end
    end

    # Used to indicate that there's no serializer for an object class or type
    class NotFoundError < Error
      attr_reader :object, :classes

      def initialize(object, classes)
        super()
        @object = object
        @classes = classes
      end

      def message
        "No serializer found for #{object.inspect} in #{classes.join(',')}."
      end
    end

    # Used to indicate when there's a problem with an item from includes
    class IncludeError < Error
      attr_reader :include_item, :klass

      def initialize(include_item, klass)
        super()
        @include_item = include_item
        @klass = klass
      end

      def message
        "#{include_item} is not available on #{klass}"
      end
    end
  end
end
