module FastJsonapi
  class Scalar
    attr_reader :key, :method, :conditional, :serializer

    def initialize(key:, method:, options: {}, serializer:)
      @key = key
      @method = method
      @conditional = options[:if]
      @serializer = serializer
    end

    def serialize(record, serialization_params, output_hash)
      if conditionally_allowed?(record, serialization_params)
        if method.is_a?(Proc)
          output_hash[key] = FastJsonapi.call_proc(method, record, serialization_params)
        else
          output_hash[key] = record.public_send(method)
        end
      end
    end

    def conditionally_allowed?(record, serialization_params)
      return true unless conditional.present?

      conditional_proc = if conditional.is_a? Symbol
                           serializer.new(record, serialization_params).method(conditional).to_proc
                         else
                           conditional
                         end
      FastJsonapi.call_proc(conditional_proc, record, serialization_params)
    end
  end
end
