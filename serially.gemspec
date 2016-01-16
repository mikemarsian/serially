# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'serially/version'

Gem::Specification.new do |spec|
  spec.name          = "serially"
  spec.version       = Serially::VERSION
  spec.authors       = ["Mike Polischuk"]
  spec.email         = ["mike@polischuk.net"]

  spec.summary       = %q{Allows any plain ruby class or ActiveRecord model to define a series of background tasks that will be run serially, strictly one
                        after another, as a single, long-running resque job}
  spec.homepage      = "http://github.com/mikemarsian/serially"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 1.9.3'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'resque', '~> 1.2'
  spec.add_dependency 'resque-lonely_job'
  spec.add_dependency 'activerecord', '~> 4.2'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", '~> 3.0'
  spec.add_development_dependency "rspec_junit_formatter", '0.2.2'
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-debugger"
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'sqlite3'

  spec.description   = <<desc
Have you ever had a class whose instances required a series of background tasks to run serially, strictly one after another? Than Serially is for you.
Declare the tasks using a simple DSL in the order you want them to to run. The tasks for each instance will run inside a separate Resque job, in a queue you specify. The next task will run only if the previous one has finished successfully. All task runs are written to DB and can be inspected.
desc

end
