require 'roart'

def dbtime(time)
  time.strftime("%Y-%m-%d %H:%M:%S")
end

def to_content_format(data)
  fields = data.map { |key,value| "#{key.to_s.camelize}: #{value}" unless value.nil? }
  fields.compact.sort.join("\n")
end

RSpec.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

# EOF
