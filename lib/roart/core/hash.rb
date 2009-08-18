class Hash
  def to_content_format
    fields = self.map { |key,value| "#{key.to_s.camelize}: #{value}" unless value.nil? }
    content = fields.compact.join("\n")
  end
  
end