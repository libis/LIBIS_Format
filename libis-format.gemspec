# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'libis/format/version'
require 'bundler'

Gem::Specification.new do |spec|
  spec.name          = 'libis-format'
  spec.version       = Libis::Format::VERSION
  spec.authors       = ['Kris Dekeyser']
  spec.email         = ['kris.dekeyser@libis.be']
  spec.summary       = 'LIBIS File format format services.'
  spec.description   = 'Collection of tools and classes that help to identify file formats and create derivative copies.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.platform      = Gem::Platform::JAVA if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
  spec.required_ruby_version = '>= 3.2'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(bin/|lib/|data/|tools/|Gemfile|libis-format.gemspec|LICENSE\.txt|README\.md)})
  end
  spec.executables   = spec.files.grep(%r{^bin/[^/]+$}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'chromaprint', '~> 0.0.2'
  spec.add_runtime_dependency 'deep_dive', '~> 0.3'
  spec.add_runtime_dependency 'libis-mapi', '~> 0.3'
  spec.add_runtime_dependency 'libis-tools', '~> 1.1'
  spec.add_runtime_dependency 'mini_magick', '~> 5.0.1'
  spec.add_runtime_dependency 'naturally', '~> 2.2'
  spec.add_runtime_dependency 'new_rfc_2047', '~> 1.0'
  spec.add_runtime_dependency 'os', '~> 1.1'
  spec.add_runtime_dependency 'pdfinfo', '~> 1.4'
  spec.add_runtime_dependency 'pdfkit', '~> 0.8'

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'equivalent-xml'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  if Gem::Platform::JAVA && spec.platform == Gem::Platform::JAVA
    spec.add_development_dependency 'saxon-xslt'
  else
    spec.add_development_dependency 'nokogiri'
  end
end
