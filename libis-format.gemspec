# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'libis/format/version'
require 'bundler'

Gem::Specification.new do |spec|
  spec.name          = 'libis-format'
  spec.version       = Libis::Format::VERSION
  spec.authors       = ['Kris Dekeyser']
  spec.email         = ['kris.dekeyser@libis.be']
  spec.summary       = %q{LIBIS File format format services.}
  spec.description   = %q{Collection of tools and classes that help to identify formats of binary files and create derivative copies (e.g. PDF from Word).}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.platform      = Gem::Platform::JAVA if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^bin/[^/]+$}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'equivalent-xml', '~> 0.5'
  if Gem::Platform::JAVA && spec.platform == Gem::Platform::JAVA
    spec.add_development_dependency 'saxon-xslt'
  else
    spec.add_development_dependency 'nokogiri'
  end

  spec.add_runtime_dependency 'libis-tools', '~> 1.0'
  spec.add_runtime_dependency 'os', '= 0.9.6'
  spec.add_runtime_dependency 'mini_magick', '~> 4.3'
  spec.add_runtime_dependency 'deep_dive', '~> 0.3'
  spec.add_runtime_dependency 'chromaprint', '~> 0.0.2'
  spec.add_runtime_dependency 'naturally', '~> 2.1'
  spec.add_runtime_dependency 'pdfinfo', '~> 1.4'
  spec.add_runtime_dependency 'ruby-msg-nx'
  spec.add_runtime_dependency 'new_rfc_2047'
  spec.add_runtime_dependency 'pdfkit'

end