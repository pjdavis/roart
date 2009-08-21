class Array
  
  def to_hash
    h = Hash.new
    self.each do |element|
      h.update(element.to_sym => "")
    end
    h
  end
  
end