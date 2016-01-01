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
Have you ever had a class that required a series of background tasks to run serially, strictly one after another? Than Serially is for you.
All background jobs are scheduled using resque and Serially makes sure that for every instance of your class, only one task runs at a time.
Different instances of the same class do not interfere with each other and their tasks can run in parallel.
Serially works for both plain ruby classes and ActiveRecord models. In case of the latter, all task runs results are written to serially_tasks table which you can interrogate pragmatically using Serially::TaskRun model.
desc

end
