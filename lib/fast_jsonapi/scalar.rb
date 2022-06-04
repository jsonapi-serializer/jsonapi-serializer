module FastJsonapi
  class Scalar
    attr_reader :key, :method, :conditional_proc, :optional

    def initialize(key:, method:, options: {})
      @key = key
      @method = method
      @conditional_proc = options[:if]
      @optional = options[:optional] || false
    end

    def serialize(record, serialization_params, output_hash, allowed_optionals)
      if conditionally_allowed?(record, serialization_params, allowed_optionals)
        if method.is_a?(Proc)
          output_hash[key] = FastJsonapi.call_proc(method, record, serialization_params)
        else
          output_hash[key] = record.public_send(method)
        end
      end
    end

    def conditionally_allowed?(record, serialization_params, allowed_optionals)
      return false if optional.present? && !allowed_optionals.include?(@key)

      if conditional_proc.present?
        FastJsonapi.call_proc(conditional_proc, record, serialization_params)
      else
        true
      end
    end
  end
end
