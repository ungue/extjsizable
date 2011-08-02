module Extjsizable
  module ActiveRecord
    module ExtJs
      extend ActiveSupport::Concern

      module InstanceMethods

        def to_ext_json(options = {})
          success = options.delete(:success)
          methods = Array(options.delete(:methods))
          include_model_name = options.has_key?(:wrap_attribute_model) ? options.delete(:wrap_attribute_model) : Extjsizable.config.wrap_attribute_model

          if success || (success.nil? && valid?)
            # returns success/data to load a form:
            # {
            #   "data": { 
            #     "post[id]": 1, "post[title]": "First Post",
            #     "post[body]": "This is my first post.",
            #     "post[published]": true, ...
            #    }, 
            #    "success": true
            # }
            data =  attributes.map{ |name, value| [extjs_attr_name(name, include_model_name), value] }
            methods.each do |method|
              data << [extjs_attr_name(method, include_model_name), self.send(method)] if self.respond_to? method
            end
          
            { :success => true, :data => Hash[*data.flatten(1)] }.to_json(options)

          else
            # retrieves no-success/errors to the form:
            # {"errors": { "post[title]": "Title can't be blank", ... },
            # "success": false }
            error_hash = errors.inject({}) do |result, error| # error is [attribute, message]
              field_key = extjs_attr_name(error.first, include_model_name)
              result[field_key] ||= Array(errors[error.first]).to_sentence
              result
            end
            { :success => false, :errors => error_hash }.to_json(options)
          end
        end
        
        private
        
        def extjs_attr_name(name, include_model_name = false)
          include_model_name ? "#{self.class.to_s.demodulize.underscore}[#{name}]" : name.to_s
        end
      end
    end
  end
end

