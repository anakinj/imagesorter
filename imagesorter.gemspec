# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

Gem::Specification.new do |s|
  s.name              = 'imagesorter'
  s.version           = File.read(File.expand_path('version', __dir__)).strip
  s.description       = 'Command line tool for sorting photos and videos'
  s.summary           = 'Command line tool for sorting photos and videos'
  s.authors           = ['Joakim Antman']
  s.email             = 'antmanj@gmail.com'

  s.homepage          = 'https://github.com/anakinj/imagesorter'
  s.license           = 'MIT'
  s.require_paths     = ['lib']
  s.files             = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.bindir            = 'exe'
  s.executables       = s.files.grep(%r{^exe/}) { |f| File.basename(f) }

  s.required_ruby_version = '>= 2.4'

  s.add_dependency 'exifr'
  s.add_dependency 'progressbar'
  s.add_dependency 'r18n-core'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'simplecov'
end
