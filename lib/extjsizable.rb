require 'active_support/core_ext'
require 'active_support/concern'
require 'extjsizable/config'
require 'extjsizable/active_record/extjs'
require 'extjsizable/core_ext/array/extjs'

module Extjsizable
  def self.config
    @_config ||= Config.new
  end
end

ActiveRecord::Base.send :include, Extjsizable::ActiveRecord::ExtJs
Array.send              :include, Extjsizable::CoreExt::Array::ExtJs
