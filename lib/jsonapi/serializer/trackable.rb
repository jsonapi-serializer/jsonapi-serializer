# frozen_string_literal: true

module JSONAPI
  module Serializer
    # Allows tracking and registering the descendant serializer classes
    module Trackable
      # Adds a [Class] to the list of known serializers
      #
      # Mostly used internally to resolve easily record serializer classes
      #
      # @param klass [Class] to add to the list of known serializers
      # @return [Class] or nothing if the class is already cached
      def register_serializer(klass)
        @serializers ||= []
        @serializers << klass unless @serializers.include?(klass)
      end

      # Returns a list of available serializers
      #
      # @return [Array] of classes
      def serializers
        @serializers
      end

      # Returns the serializer class for a record/object
      #
      # It follows the basic convention that the object class name and its
      # serializer class name are in the same namespace and the later ends
      # with the name `Serializer`.
      #
      # Ex.: [MyApp::UserModel] has the serializer [MyApp::UserModelSerializer]
      #
      # @param object [Object] to find the serialization class for
      # @param mapping [Hash] custom map of model to serializer classes
      # @return [Class] of the serialization class
      def for_object(object, mapping = nil)
        if mapping.is_a?(Hash)
          return (
            mapping[object.class] || NotFoundError.new(object, mapping.values)
          )
        end

        serializers.each do |klass|
          return klass if klass.name == "#{object.class.name}Serializer"
        end

        raise NotFoundError.new(object, serializers)
      end

      # Returns the serializer class for a type
      #
      # It looks for existing serializers types that match
      #
      # Ex.: [MyApp::UserModelSerializer.record_type] would be `user`.
      #
      # @param record_type [String] to find the serialization class for
      # @param mapping [Hash] custom map of model to serializer classes
      # @return [Class] of the serialization class
      def for_type(record_type, mapping = nil)
        classes = mapping.values if mapping.is_a?(Hash)
        classes ||= serializers

        classes.each do |klass|
          return klass if klass.record_type.to_s == record_type.to_s
        end

        raise NotFoundError.new(record_type, classes)
      end
    end
  end
end
