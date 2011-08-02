require 'active_record'
require 'active_support/core_ext'
require 'active_support/concern'
require 'extjsizable/active_record/extjs'
require 'extjsizable/core_ext/array/extjs'

ActiveRecord::Base.send :include, Extjsizable::ActiveRecord::ExtJs
Array.send              :include, Extjsizable::CoreExt::Array::ExtJs
