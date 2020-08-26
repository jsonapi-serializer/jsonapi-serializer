require 'fast_jsonapi/instrumentation/skylight/normalizers/base'
require 'fast_jsonapi/instrumentation/serializable_hash'

module FastJsonapi
  module Instrumentation
    module Skylight
      module Normalizers
        class SerializedJson < SKYLIGHT_NORMALIZER_BASE_CLASS
          register JSONAPI::Serializer::SERIALIZED_JSON_NOTIFICATION

          CAT = "view.#{JSONAPI::Serializer::SERIALIZED_JSON_NOTIFICATION}".freeze

          def normalize(_trace, _name, payload)
            [CAT, payload[:name], nil]
          end
        end
      end
    end
  end
end
