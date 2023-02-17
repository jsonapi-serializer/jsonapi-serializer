require 'fast_jsonapi/conditional'

module FastJsonapi
  class Scalar
    attr_reader :key, :method, :conditional

    def initialize(key:, method:, options: {})
      @key = key
      @method = method
      @conditional = Conditional.new(options.slice(*Conditional::CONDITIONAL_KEYS))
    end

    def serialize(record, serialization_params, output_hash)
      if conditional.allowed?(record: record, serialization_params: serialization_params)
        if method.is_a?(Proc)
          output_hash[key] = FastJsonapi.call_proc(method, record, serialization_params)
        else
          output_hash[key] = record.public_send(method)
        end
      end
    end
  end
end
