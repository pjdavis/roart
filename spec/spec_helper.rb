
dir = File.dirname(__FILE__)

$:.unshift(File.join(dir, '/../lib/'))
require dir + '/../lib/roart'

def dbtime(time)
  time.strftime("%Y-%m-%d %H:%M:%S")
end

Spec::Runner.configure do |config|
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
