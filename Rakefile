# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'roart'

task :default => 'spec:run'

PROJ.name = 'roart'
PROJ.ignore_file = '.gitignore'
PROJ.authors = 'PJ Davis'
PROJ.email = 'pj.davis@gmail.com'
PROJ.url = 'http://github.com/pjdavis/roart'
PROJ.version = Roart::VERSION
PROJ.rubyforge.name = 'roart'
PROJ.exclude = %w(.git pkg coverage)
PROJ.description = "Interface for working with Request Tracker (RT) tickets inspired by ActiveRecord."
PROJ.rdoc.main = 'README.rdoc'
depend_on 'mechanize'

PROJ.spec.opts << '--color --heckle'

# EOF
