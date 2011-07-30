module Extjsizable
  class Config
    attr_accessor :wrap_attribute_model

    def initialize(opts = {})
      opts.reverse_merge! :wrap_attribute_model => true

      opts.each { |method, v| self.send("#{method}=", v) if self.respond_to?("#{method}=")}
    end

  end
end
