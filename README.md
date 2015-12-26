# Serially

[![Build Status](https://circleci.com/gh/mikemarsian/serially.svg?&style=shield&circle-token=93a8f2925ebdd64032108118ef6e17eb3848d767)](https://circleci.com/gh/mikemarsian/serially)
[![Code Climate](https://codeclimate.com/github/mikemarsian/serially/badges/gpa.svg)](https://codeclimate.com/github/mikemarsian/serially)

Have you ever had a plain ruby class or an ActiveRecord model, that needed to define a series of background tasks, that for each instance of that class had to run serially, strictly one after another? Than Serially is for you.
All background jobs are scheduled using resque in a queue called `serially', and Serially makes sure that for every instance of your class, only one task runs at a time. Different instances of the same class do not interfere with each other and their tasks can run in parallel.

Note: this gem is in active development and currently is not intended to run in production.

## Usage
```ruby
class Invoice < ActiveRecord::Base
     include Serially

     serially do
        task :enrich
        task :verify
        task :refund
        task :archive
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

     def archive
        puts "Archiving invoice #{self.id}"
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
Archiving invoice 15
Archiving invoice 16

```


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

