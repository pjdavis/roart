module Roart
  
  def self.check_keys!(hash, required)
    unless required.inject(true) do |inc, attr| 
        inc ? hash.keys.include?(attr.to_sym) : nil
      end
      raise ArgumentError, "Not all required fields entered" 
    end
  end
  
end