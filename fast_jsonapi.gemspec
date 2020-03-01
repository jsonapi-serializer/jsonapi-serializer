lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fast_jsonapi/version'

Gem::Specification.new do |gem|
  gem.name = 'fast_jsonapi'
  gem.version = FastJsonapi::VERSION

  gem.authors = [
    'Shishir Kakaraddi',
    'Srinivas Raghunathan',
    'Adam Gross',
    'github/fast-jsonapi community'
  ]
  gem.email = ''

  gem.summary = 'Fast JSON:API (jsonapi.org) serialization library'
  gem.description =
    'Fast JSON:API (jsonapi.org) serialization library ' \
    'to work with any kind of objects'
  gem.homepage = 'http://github.com/fast-jsonapi/fast_jsonapi'
  gem.licenses = ['Apache-2.0']
  gem.files = Dir['lib/**/*']
  gem.require_paths = ['lib']
  gem.extra_rdoc_files = ['LICENSE.txt', 'README.md']

  gem.add_runtime_dependency('activesupport', '>= 4.2')

  gem.add_development_dependency('activerecord')
  gem.add_development_dependency('bundler')
  gem.add_development_dependency('byebug')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('sqlite3')
  gem.add_development_dependency('simplecov')
end
