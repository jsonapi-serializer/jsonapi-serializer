module FastJsonapi
  class << self
    # Calls either a Proc or a Lambda, making sure to never pass more parameters to it than it can receive
    #
    # @param [Proc] proc the Proc or Lambda to call
    # @param [Array<Object>] *params any number of parameters to be passed to the Proc
    # @return [Object] the result of the Proc call with the supplied parameters
    def call_proc(proc, *params)
      proc.call(*params.take(proc.parameters.length))
    end
  end
end
