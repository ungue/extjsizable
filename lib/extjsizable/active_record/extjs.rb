module Extjsizable
  module ActiveRecord
    module ExtJs
      extend ActiveSupport::Concern

      module InstanceMethods

        def to_extjs(options = {})
          success = options.delete(:success)

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
          
            h_json_data = ::ActiveRecord::Base.include_root_in_json? ? as_json(options) : { :data => as_json(options) }
            { :success => true }.merge(h_json_data)
          else
            # retrieves no-success/errors to the form:
            # {
            #   "errors": { "title": "Title can't be blank", ... },
            #   "success": false 
            # }
            { :success => false, :errors => errors.as_json(options).with_indifferent_access }
          end.with_indifferent_access 

        end        
      end
    end
  end
end

