module Roart
  
  module TicketPage

    def to_hash
      hash = Hash.new
      self.delete_if{|x| !x.include?(":")}
      self.each do |ln|
        ln = ln.split(":")
        key = ln.delete_at(0).strip.underscore
        value = ln.join(":").strip
        hash[key.to_sym] = value
      end
      hash[:id] = hash[:id].split("/").last.to_i
      hash.update(:history => false)
      hash
    end
    
    def to_search_array
      array = Array.new
      self.delete_if{|x| !x.include?(":")}
      self.each do |ln|
        hash = Hash.new
        ln = ln.split(":")
        id = ln.delete_at(0).strip.underscore
        sub = ln.join(":").strip
        hash[:id] = id.to_i
        hash[:subject] = sub
        hash[:full] = false
        hash[:history] = false
        array << hash
      end
      array
    end
    
  end
  
end