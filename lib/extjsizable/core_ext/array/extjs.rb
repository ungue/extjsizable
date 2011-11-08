module Extjsizable
  module CoreExt
    module Array
      module ExtJs
        extend ActiveSupport::Concern

        included do
          class_attribute :dasherize_keys

          self.dasherize_keys = false
        end

        module InstanceMethods

          # Creates a JSON object by specifying which attributes we want to be shown.
          # Ej:
          # { 'total' : 2,
          #   'data' : [
          #      { 'id' : 1, :nombre : 'Juan'  },
          #      { 'id' : 2, :nombre : 'Pedro' }
          #    ]
          # }
          
          def to_extjs(options = {})
            array_json_data = as_json(options)

            if ::Array.dasherize_keys?
              array_json_data.map! { |h| dasherize_hash_keys(h) }
            end

            { :total => (options.delete(:total) || self.length), :data => array_json_data }.with_indifferent_access
          end

          private
            
          # Dasherize keys that {:a => {:b => :c} } becomes to { 'a_b' => :c }
          def dasherize_hash_keys(h, dash_key = '')
            return { dash_key => h } unless h.is_a?(Hash)

            h.reduce({}) do |nh, (k, v)|
              nh.merge(dasherize_hash_keys(v, dash_key.blank? ? k.to_s : "#{dash_key}_#{k.to_s}"))
            end
          end

        end
      end
    end
  end
end
