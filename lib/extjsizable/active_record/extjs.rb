module Extjsizable
  module ActiveRecord
    module ExtJs
      extend ActiveSupport::Concern

      included do
        class_attribute :wrap_with_brackets

        self.wrap_with_brackets = false
      end

      module InstanceMethods

        def to_extjs(options = {})
          success = options.delete(:success)
          underscored_class_name = self.class.to_s.demodulize.underscore

          if success || (success.nil? && valid?)
            # returns success/data to load a form:
            # {
            #   "data": { 
            #     "id": 1, 
            #     "title": "First Post",
            #     "body": "This is my first post.",
            #     "published": true, ...
            #    }, 
            #    "success": true
            # }
            # 
            # If ActiveRecord::Base.include_root_in_json is true then, the model name is used instead of data key:
            # {
            #   "post": { 
            #     "id": 1, 
            #     "title": "First Post",
            #     "body": "This is my first post.",
            #     "published": true, ...
            #    }, 
            #    "success": true
            # }
            # If ActiveRecord::Base.wrap_with_brackets is true then, the model name is prefixed into data key and all keys are surrounded with brackets:
            # {
            #   "data": { 
            #     "post[id]": 1, 
            #     "post[title]": "First Post",
            #     "post[body]": "This is my first post.",
            #     "post[published]": true, ...
            #    }, 
            #    "success": true
            # }
 
            h_json_data = as_json(options)
            h_json_data = { :data => h_json_data } unless ::ActiveRecord::Base.include_root_in_json?
            h_json_data[h_json_data.keys.first] = wrap_hash_with_brackets(h_json_data.values.first, underscored_class_name) if ::ActiveRecord::Base.wrap_with_brackets?

            { :success => true }.merge(h_json_data)
          else
            # retrieves no-success/errors to the form:
            # {
            #   "errors": { "title": "Title can't be blank", ... },
            #   "success": false 
            # }

            h_json_data = errors.as_json(options)
            h_json_data = wrap_hash_with_brackets(h_json_data, underscored_class_name) if ::ActiveRecord::Base.wrap_with_brackets?
            { :success => false, :errors => h_json_data.with_indifferent_access }
          end.with_indifferent_access 

        end        
      end

      private

      # Wrap with brackets so that {:a => {:b => :c} } becomes to { 'model[a][b]' => :c }
      def wrap_hash_with_brackets(h, bracket_key = '')
        return { bracket_key => h } unless h.is_a?(Hash)

        h.reduce({}) do |nh, (k, v)|
          nh.merge(wrap_hash_with_brackets(v, bracket_key + "[#{k.to_s}]"))
        end
      end
    end
  end
end

