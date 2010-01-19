module Roart
  
  def self.check_keys!(hash, required)
    puts hash
    unless required.inject(true) do |inc, attr| 
        inc ? hash.keys.include?(attr.to_sym) : nil
      end
      raise ArgumentError, "Not all required fields entered" 
    end
  end
  
  def self.check_keys(hash, required)
    unless required.inject(true) do |inc, attr| 
        inc ? hash.keys.include?(attr.to_sym) : nil
      end
      return false
    end
    return true
  end
  
  module MethodFunctions
    
    def add_methods!
      @attributes.each do |key, value|
        (class << self; self; end).send :define_method, key do
          return @attributes[key]
        end
        (class << self; self; end).send :define_method, "#{key}=" do |new_val|
          @attributes[key] = new_val
        end
      end 
    end
    
  end
  
end