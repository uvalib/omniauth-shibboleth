$LOAD_PATH.unshift File.expand_path("..", __FILE__)
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'rspec'
require 'rack/test'
require 'rack/mock'
require 'omniauth'
require 'omniauth/strategy'
require 'omniauth/test'
require 'omniauth-shibboleth'

RSpec.configure do |config|
  config.extend OmniAuth::Test::StrategyMacros, :type => :strategy
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

end

