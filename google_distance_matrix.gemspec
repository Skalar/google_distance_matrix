# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_distance_matrix/version'

Gem::Specification.new do |spec|
  spec.name          = "google_distance_matrix"
  spec.version       = GoogleDistanceMatrix::VERSION
  spec.authors       = ["Thorbjørn Hermansen"]
  spec.email         = ["thhermansen@gmail.com"]
  spec.description   = %q{Simple client for Google's Distance Matrix API}
  spec.summary       = %q{Simple client for Google's Distance Matrix API}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
