# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/shibboleth'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-shibboleth"
  spec.version       = OmniAuth::Shibboleth::VERSION
  spec.authors       = ["Michael Durbin"]
  spec.email         = ["md5wz@virginia.edu"]
  spec.description   = %q{An omni-auth strategy for UVA's shibboleth implementation, requiring the apache Shibboleth plugin.}
  spec.summary       = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'omniauth', '~> 1.2.1'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'omniauth', '~> 1.2.1'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.99.0.beta1'
  spec.add_development_dependency 'rack-test', '~> 0.5'
end
