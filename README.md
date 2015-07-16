# HuginnAgent

TODO: Write a gem description

## Installation

Add this line to your Huginn Gemfile:

```ruby
gem 'huginn_agent'
```

Then create an initializer at ```config/huginn_agent.rb```, with the following code:

## Sample code

```ruby
require 'huginn_agent'

HuginnAgent.hack_huginn_to_accept_me
```

## Sample agent



Happy.emit
```

## Usage

Create a HuginnAgent like so:

```ruby
require 'huginn_agent'

HuginnAgent.hack_huginn_to_accept_me

class Happy < HuginnAgent
  def self.description
<<STUFF
#Happy

This is a test agent.
STUFF
  end
end
```

This code can be in a separate gem.

Then in your huginn initializer, add:

```ruby
Happy.emit
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/huginn_agent/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
