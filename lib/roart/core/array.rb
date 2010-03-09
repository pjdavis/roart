class Array

  def to_hash
    h = HashWithIndifferentAccess.new
    self.each do |element|
      h.update(element => nil)
    end
    h
  end

end