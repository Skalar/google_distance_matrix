# frozen_String_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_distance_matrix/version'

Gem::Specification.new do |spec|
  spec.name          = 'google_distance_matrix'
  spec.version       = GoogleDistanceMatrix::VERSION
  spec.authors       = ['Thorbjørn Hermansen']
  spec.email         = ['thhermansen@gmail.com']
  spec.description   = %(Ruby client for The Google Distance Matrix API)
  spec.summary       = %(Ruby client for The Google Distance Matrix API)
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($RS)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.0'

  spec.add_dependency 'activemodel', '>= 3.2.13', '< 8.1'
  spec.add_dependency 'activesupport', '>= 3.2.13', '< 8.1'
  spec.add_dependency 'google_business_api_url_signer', '~> 0.1.3'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.13.0'
  spec.add_development_dependency 'rubocop', '~> 0.93.1'
  spec.add_development_dependency 'shoulda-matchers', '~> 6.0'
  spec.add_development_dependency 'webmock', '~> 3.23.1'
end
