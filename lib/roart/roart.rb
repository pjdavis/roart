module Roart
  
  def self.check_keys!(hash, required)
    unless required.inject(true) do |inc, attr| 
        inc ? hash.keys.include?(attr.to_sym) : nil
      end
      raise ArgumentError, "Not all required fields entered" 
    end
  end
  
  
  module MethodFunctions
    
    def add_methods!
      @attributes.each do |key, value|
        (class << self; self; end).send :define_method, key do
          return value
        end
      end 
    end
    
  end
  
end