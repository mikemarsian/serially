# Serially

[![Build Status](https://circleci.com/gh/mikemarsian/serially.svg?&style=shield&circle-token=93a8f2925ebdd64032108118ef6e17eb3848d767)](https://circleci.com/gh/mikemarsian/serially)
[![Code Climate](https://codeclimate.com/github/mikemarsian/serially/badges/gpa.svg)](https://codeclimate.com/github/mikemarsian/serially)

Have you ever had a class that required a series of background tasks to run serially, strictly one after another? Than Serially is for you.
All background jobs are scheduled using resque in a queue called `serially`, and Serially makes sure that for every instance of your class, only one task runs at a time.
Different instances of the same class do not interfere with each other and their tasks can run in parallel.
Serially works for both plain ruby classes and ActiveRecord models. In case of the latter, all task runs results for all classes are recorded in `serially_tasks` table which you can interrogate pragmatically.


Note: this gem is in active development and currently is not intended to run in production.

## Usage
```ruby
class Invoice < ActiveRecord::Base
     include Serially

     serially do
        task :enrich
        task :verify
        task :refund
     end

     def enrich
        puts "Enriching invoice #{self.id}"
     end

     def verify
        puts "Verifying invoice #{self.id}"
     end

     def refund
        puts "Refunding invoice #{self.id}"
     end
   end
```

After creating an instance of Invoice, you can run `invoice.serially.start!` to schedule your tasks to run serially. They will run one after the other in the scope of a single resque `Serially::Worker` job.
An example run:
```ruby
invoice1 = Invoice.create(country: 'FR', amount: '100') #=> <Invoice id: 15, country: 'FR', amount: 100>
invoice2 = Invoice.create(country: 'GB', amount: 150)   #=> <Invoice id: 16, country: 'GB', amount: 150>
invoice1.serially.start!
invoice2.serially.start!
```
The resulting resque log may look something like this:
```
Enriching invoice 15
Enriching invoice 16
Verifying invoice 16
Refunding invoice 16
Verifying invoice 15
Refunding invoice 15
```

In addition to instance methods, you can pass blocks as callbacks to your class, and you can mix both syntaxes in your class:

```ruby
class Invoice < ActiveRecord::Base
     include Serially

     serially do
        task :prepare
        task :enrich do |instance|
            puts "Enriching #{instance.id}"
        end
        task :verify do |instance|
            puts "Verifying #{instance.id}"
        end
     end

     def prepare
        puts "Preparing #{self.id}"
     end
end
```

## Customizing Instance Creation
Before the first task runs, an instance of your class is created, on which your task callbacks are then called. By default, instances of plain ruby classes
are created using `new(self.instance_args)`, while instances of ActiveRecord models are loaded using `where(self.instance_args).first`.

### Plain Ruby Class
The default implementation of `instance_args` for a plain ruby class returns nil (in which case `new` is called without arguments). You can provide your own
implementation of `instance_args`, and then it will be used when instantiating an instance:

```ruby
class MyClass
     include Serially

     attr_accessor :some_key
     def initialize(args)
        @some_key = args[:some_key]
     end

     def instance_args
        {some_key: self.some_key}
     end


     serially do
        task :do_this
        task :do_that
     end

     def do_this
        puts "Doing this for instance with some_key=#{self.some_key}"
     end
     def do_that
        puts "Doing that for instance with some_key=#{self.some_key}"
     end
end

# somewhere in your code you create an instance of your class and call #serially.start!
my = MyClass.new(some_key: "IamMe")
my.serially.start!   # Serially::Worker is enqueued in resque queue

# resque picks up the job, creates an instance of your class using self.instance_args your provided, and starts executing tasks.
```

Here's the resulting resque log:
```
Doing this for instance with some_key=IamMe
Doing that for instance with some_key=IamMe
```

### ActiveRecord Model


## Termination


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'serially'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install serially


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mikemarsian/serially.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

