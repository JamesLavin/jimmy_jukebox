RSpec.configure do |config|
  config.before(:suite) do
    ARGV.clear
  end
end

require 'fakefs/spec_helpers'

