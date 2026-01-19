module FastJsonapi
  class Conditional
    CONDITIONAL_KEYS = %i[if unless].freeze

    def initialize(conditional_params)
      @if_condition = conditional_params[:if]
      @unless_condition = conditional_params[:unless]
    end

    def allowed?(record:, serialization_params:)
      if_allowed?(record, serialization_params) && unless_allowed?(record, serialization_params)
    end

    private

    attr_reader :if_condition, :unless_condition

    def if_allowed?(record, serialization_params)
      if_condition.present? ? check_condition?(if_condition, record, serialization_params) : true
    end

    def unless_allowed?(record, serialization_params)
      unless_condition.present? ? !check_condition?(unless_condition, record, serialization_params) : true
    end

    def check_condition?(condition, record, serialization_params)
      FastJsonapi.call_proc(condition, record, serialization_params)
    end
  end
end
