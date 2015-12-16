# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'serially/version'

Gem::Specification.new do |spec|
  spec.name          = "serially"
  spec.version       = Serially::VERSION
  spec.authors       = ["Mike Polischuk"]
  spec.email         = ["mike@polischuk.net"]

  spec.summary       = %q{Allows any entity class (i.e. Post, Comment) to define tasks that will be run serially, one
                        after another, as a continuous resque job}
  spec.homepage      = "http://github.com/mikemarsian/serially"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'resque', '>= 1.2'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", '>= 3.0'
  spec.add_development_dependency "mock_redis"
  spec.add_development_dependency "pry"

  spec.description   = <<desc
Allows any entity class (i.e. Post, Comment) to define tasks that will be run serially, one after another, as a continuous resque job
Example:
  require 'serially'
  class StrictlySerialJob
    include Serially
    # To Fill
  end
desc

end
