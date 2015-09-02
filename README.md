# HuginnAgent

A base agent that you can use to create your own Huginn agents.

These gems can be in their own separate gem, without any tie to Huginn.

When you start your Huginn application with this gem installed, any
```HuginnAgent``` classes you defined will be incorporated into
your Huginn application automatically.

## Installation

Add this line to your Huginn app's Gemfile:

```ruby
gem 'huginn_agent'
```

And then execute:

    $ bundle

Now inside your Huginn app, create ```config/initializers/huginn_agent.rb``` with
the following:

```ruby
require 'huginn_agent'
HuginnAgent.hack_huginn_to_accept_me
HuginnAgent.types.each { |t| t.emit }
```


## Creating an agent

Here's the simplest HuginnAgent:

```ruby
class Happy < HuginnAgent
end
```

When you inherit from ```HuginnAgent```, your agent will automatically be recognized.  You just have to get it into your web application, somehow. Here are a couple possibilities:

  1) Put your agent in your gem.  Then add a link to your gem in your Huginn app's Gemfile.
  2) Put the agent in your Huginn app. 

*Note: Rails may not load the Ruby file unless it sees some sort of hard reference to the file. (go figure?) If your agent isn't loaded, try referencing it in your initializer: *

```ruby
require 'huginn_agent'

Happy # <== now Rails will look at models/happy.rb, thanks Rails

HuginnAgent.hack_huginn_to_accept_me
HuginnAgent.types.each { |t| t.emit }
```

However you choose to load this agent, it will be made available as ```HappyAgent``` in your list of available agents.

![images/01.png](images/01.png)

But what does it do?  We should add an agent description so others will know.

```ruby
class Happy < HuginnAgent

  def self.description
    'Make the world a happy place'
  end

end
```

![images/02.png](images/02.png)

![images/03.png](images/03.png)

That's good... but does our agent really make the world a better place? It looks like it does nothing to me.

Let's make it do something.

### Checking for Anything

Let's start by adding a ```check``` method.  This method will be called whenever the agent is scheduled to run.

```ruby
class Happy < HuginnAgent

  def self.description
    'Make the world a happy place'
  end

  def check
  end

end
```

Adding this method opens the ability to schedule the agent. Whenever the agent is scheduled to run, the ```check``` method will be run.

![images/04.png](images/04.png)

### Creating Events

Our ```HappyAgent``` can be scheduled, but it still doesn't do anything. Let's have it blast a ray of sunshine... in the form of an event.

```ruby
class Happy < HuginnAgent

  def self.description
    'Make the world a happy place'
  end

  def check
    create_event payload: { blast: 'A ray of sunshine' }
  end

end
```

So I'll create the agent, name it "Smiles", and schedule it to run every minute. Look at it go!

![images/05.png](images/05.png)

If this agent was tasked with things more complicated than basic happiness, I could put all sorts of custom logic in this method to look up stuff, parse results, and create fancier events.

### Receiving Events

So agents don't have to just create events, they can also receive them.  Let's go to the dark side and create a Sad Agent, which will watch out for those happy events and make them sad.

Since this agent will be receiving events, we'll need to add a ```receive``` method with one ```events``` argument. 
This method will be passed any events the agent is subscribed to.

```ruby
class Sad < HuginnAgent

  def self.description
    'Make the world an unhappy place'
  end

  def receive events
  end

end
```

![images/06.png](images/06.png)

Let's create an agent that will receive the events from the "Smiles" Happy Agent we created, and turn them into sadness.

```ruby
class Sad < HuginnAgent

  def self.description
    'Make the world an unhappy place'
  end

  def receive events
    events.each do |event|
      if event.payload['blast']
        event.payload['blast'].gsub! 'sunshine', 'darkness'
        create_event payload: event.payload
      end
    end
  end

end
```

![images/07.png](images/07.png)

Now whenever the "Smiles" agent fires an agent, the Sadness agent will pick it up and corrupt its positive message blast.

![images/08.png](images/08.png)


## Contributing

1. Fork it ( https://github.com/[my-github-username]/huginn_agent/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
