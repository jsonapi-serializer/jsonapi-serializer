lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "fast_jsonapi/version"

Gem::Specification.new do |gem|
  gem.name = "fast_jsonapi"
  gem.version = FastJsonapi::VERSION
  gem.authors = ["Shishir Kakaraddi", "Srinivas Raghunathan", "Adam Gross"]
  gem.email = ''

  gem.summary = 'Fast JSONAPI serializer implementation'
  gem.description = 'JSONAPI (jsonapi.org) serializer that works with rails and can be used to serialize any kind of ruby objects'
  gem.homepage = "http://github.com/fast-jsonapi/fast_jsonapi"
  gem.licenses = ["Apache-2.0"]

  gem.files = Dir["lib/**/*"]
  gem.require_paths = ["lib"]
  gem.extra_rdoc_files = ["LICENSE.txt", "README.md"]

  gem.add_runtime_dependency(%q<activesupport>, [">= 4.2"])
  gem.add_development_dependency(%q<activerecord>, [">= 4.2"])
  gem.add_development_dependency(%q<skylight>, ["~> 1.3"])
  gem.add_development_dependency(%q<rspec>, ["~> 3.5.0"])
  gem.add_development_dependency(%q<oj>, ["~> 3.3"])
  gem.add_development_dependency(%q<rspec-benchmark>, ["~> 0.3.0"])
  gem.add_development_dependency(%q<bundler>, [">= 1.0"])
  gem.add_development_dependency(%q<byebug>, [">= 0"])
  gem.add_development_dependency(%q<active_model_serializers>, ["~> 0.10.7"])
  gem.add_development_dependency(%q<sqlite3>, ["~> 1.3"])
  gem.add_development_dependency(%q<jsonapi-rb>, ["~> 0.5.0"])
  gem.add_development_dependency(%q<jsonapi-serializers>, ["~> 1.0.0"])
end
