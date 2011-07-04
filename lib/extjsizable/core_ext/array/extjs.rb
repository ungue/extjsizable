module Extjsizable
  module CoreExt
    module Array
      module ExtJs

	def self.included(base)
	  base.send :include, InstanceMethods
	end

	module InstanceMethods
	  # permite bloques con argumentos al estilo &[:metodo,argumentos]
	  def to_proc
	    proc{|o| o.send *self}
	  end

	  # Crea un objeto JSON especificando los atributos que queremos que se muestren.
	  # Ej:
	  # { 'total' : 2,
	  #   'datos' : [
	  #      { 'id' : 1, :nombre : 'Juan'  },
	  #      { 'id' : 2, :nombre : 'Pedro' }
	  #    ]
	  # }
	  
	  def to_ext_json(options = {})
	    options.reverse_merge!(
	      :methods  => [],
	      :total    => self.length,
	      :only     => [],
	      :except   => [],
	      :include  => {}
	    ) 
	      
	    result = self.map do |r|
	      case r
	      when Hash
		record_from_hash(r, options)
	      when ActiveRecord::Base
		record_from_model(r, options)
	      else
		r 
	      end
	    end
	    { :total => options[:total], :datos => result }
	  end

	  private
	    

	    def record_from_model(reg, options)
	      options.reverse_merge!(
		:methods  => [],
		:only     => [],
		:except   => [],
		:include  => {}
	      )

	      data  = []

	      attrs = options[:only].empty? ? reg.attributes.symbolize_keys.keys - options[:except] : options[:only]

	      attrs.each do |attr|
		data << ["#{attr}", reg.send(attr)] if reg.respond_to? attr
	      end
	      
	      options[:methods].each do |method|
		data << ["#{method}", reg.send(method)] if reg.respond_to? method
	      end

	      options[:include].each do |(k, v)|
		data.concat record_from_model(reg.send(k), v).map { |l| ["#{k}_#{l.first}", l.last] } if reg.respond_to?(k) && reg.send(k)
	      end

	      Hash[*data.flatten(1)]
	    end

	    def record_from_hash(reg, options)
	      attrs = options[:only] || reg.keys - options[:except]
	      reg.delete_if { |k,v| attrs.member? k}
	    end
	  end

      end
    end
  end
end