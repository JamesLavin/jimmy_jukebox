RSpec.configure do |config|
  config.before(:suite) do
    ARGV.clear
  end
end
