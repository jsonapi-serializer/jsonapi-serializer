# frozen_string_literal: true

module JSONAPI
  module Serializer
    class UnsupportedIncludeError < StandardError
      attr_reader :include_item, :klass

      def initialize(include_item, klass)
        super()
        @include_item = include_item
        @klass = klass
      end

      def message
        "#{include_item} is not specified as a relationship on #{klass}"
      end
    end
  end
end
