root = File.expand_path('../../', __FILE__)
$LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)

require 'vcr'
require 'nanny'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
end

Dir[File.join("spec/support/**/*.rb")].each do |f|
  require f
end
