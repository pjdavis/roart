module Roart
  
  module Validations
    
    def self.included(base) # :nodoc:
      base.extend ClassMethods
      puts "CALLED"
    end
    
    class Errors
      include Enumerable
      
      def initialize(base)
        @base, @errors = base, {}
      end
      
      def add_to_base(msg)
        add(:base, msg)
      end
      
      def add(attr, message = nil, options = {})
        message ||= "is invalid"
        @errors[attr.to_s] ||= []
        @errors[attr.to_s] << message
      end
        
      def add_on_empty(attributes, message = nil)
        for attr in [attributes].flatten
          value = @base.send(attr.to_s)
          is_empty = value.respond_to?(:empty?) ? value.empty? : false
          add(attr, :empty, :default => custom_message) unless !value.nil? && !is_empty
        end
      end
      
      def add_on_blank(attributes, message = nil)
        for attr in [attributes].flatten
          value = @base.send(attr.to_s)
          is_empty = value.respond_to?(:blank?) ? value.blank? : false
          add(attr, :blank, :default => custom_message) unless !value.nil? && !is_blank
        end
      end
      
    end
  
    module ClassMethods
      
      def validates_presence_of(*fields)
        send(:validate) do |record|
          record.errors.add_on_blank(fields, "must be present")
        end
      end
      
    end
    
  end
  
  puts 'including validations'
  
end