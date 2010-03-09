require "#{File.dirname(__FILE__)}/hash/indifferent_access.rb"
class Hash
  def to_content_format
    fields = self.map do |key,value|
      unless value.nil?
        if key.to_s.match(/^cf_.+/)
          "CF-#{key.to_s[3..key.to_s.length].gsub(/_/, " ").camelize.humanize}: #{value}"
        else
          "#{key.to_s.camelize}: #{value}"
        end
      end
    end
    content = fields.compact.sort.join("\n")
  end

  def with_indifferent_access
    hash = HashWithIndifferentAccess.new(self)
    hash.default = self.default
    hash
  end

end