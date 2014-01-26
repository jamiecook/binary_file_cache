# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'binary_file_cache/version'

Gem::Specification.new do |spec|
  spec.name          = 'binary_file_cache'
  spec.version       = BinaryFileCache::VERSION
  spec.authors       = ['Jamie Cook']
  spec.email         = ['jamie.cook@veitchlister.com.au']
  spec.summary       = %q{Caches the result of a block on file}
  spec.description   = %q{Cache can be invalided based on changes to a set of input files}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
