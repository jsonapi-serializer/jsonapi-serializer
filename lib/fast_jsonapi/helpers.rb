module FastJsonapi
  class << self
    # Calls either a Proc or a Lambda, making sure to never pass more parameters to it than it can receive
    #
    # @param [Proc] proc the Proc or Lambda to call
    # @param [Array<Object>] *params any number of parameters to be passed to the Proc
    # @return [Object] the result of the Proc call with the supplied parameters
    def call_proc(proc, *params)
      # The parameters array for a lambda created from a symbol (&:foo) differs
      # from explictly defined procs/lambdas, so we can't deduce the number of
      # parameters from the array length. Instead, look for an unnamed
      # parameter in the first position just pass the record as the receiver obj.
      if proc.parameters.length > 0 && proc.parameters.first[1].nil?
        proc.call(params.first)
      else
        proc.call(*params.take(proc.parameters.length))
      end
    end
  end
end
