module Extjsizable
  module ActiveRecord
    module ExtJs

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def to_ext_json(options = {})
          success = options.delete(:success)
          methods = Array(options.delete(:methods))
          underscored_class_name = self.class.to_s.demodulize.underscore

          if success || (success.nil? && valid?)
            # devuelve success/data para cargar un formulario:
            # {
            #   "data": { 
            #     "post[id]": 1, "post[title]": "First Post",
            #     "post[body]": "This is my first post.",
            #     "post[published]": true, ...
            #    }, 
            #    "success": true
            # }
            data =  attributes.map{ |name, value| ["#{underscored_class_name}[#{name}]", value] }
            methods.each do |method|
              data << ["#{underscored_class_name}[#{method}]", self.send(method)] if self.respond_to? method
            end
          
            { :success => true, :data => Hash[*data.flatten(1)] }.to_json(options)

          else
            # devuelve no-success/errors al formulario:
            # {"errors": { "post[title]": "Title can't be blank", ... },
            # "success": false }
            error_hash = errors.inject({}) do |result, error| # error es [attribute, message]
              field_key = "#{underscored_class_name}[#{error.first}]"
              result[field_key] ||= Array(errors[error.first]).to_sentence
              result
            end
            { :success => false, :errors => error_hash }.to_json(options)
          end
        end
      end

    end
  end
end

