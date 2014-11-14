# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'libis/format/version'

Gem::Specification.new do |spec|
  spec.name          = 'LIBIS_Services'
  spec.version       = LIBIS::Format::VERSION
  spec.authors       = ['Kris Dekeyser']
  spec.email         = ['kris.dekeyser@libis.be']
  spec.summary       = %q{LIBIS File format format services.}
  spec.description   = %q{Collection of tools and classes that help to identify formats of binary files and create derivative copies (e.g. PDF from Word).}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_runtime_dependency 'LIBIS_Tools'
end
