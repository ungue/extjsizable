module Extjsizable
  module CoreExt
    module Array
      module ExtJs
        extend ActiveSupport::Concern

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
            { :total => (options.delete(:total) || self.length), :data => as_json(options) }.with_indifferent_access
          end

        end
      end
    end
  end
end
