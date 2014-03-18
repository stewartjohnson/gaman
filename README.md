# Gaman

**This is Alpha software still in development!**

Gaman is a gem for interacting with the First Internet Backgammon Server (FIBS).

It provides:

* A ruby API (through the {Gaman::Fibs} class) for creating a connection with
  FIBS and using all of the FIBS functions.
* A command line executable (`gaman`) for playing backgammon on FIBS. `gaman` 
  is designed for an easier console experience than directly telnetting to FIBS. `gaman` is inspired by the console email client PINE.

## Installation

Add this line to your application's Gemfile or gemspec:

    gem 'gaman'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gaman

## Usage

### Console Client

To play backgammon on the console with FIBS, type `gaman` at the terminal.

### Using the ruby API

See the Fibs class for documentation on using the ruby API.

    Gaman::Fibs.use(options) do |fibs|
      fibs.shout "Hello everyone!" # shouted to all online players
    end

## Motivation

Really, this is about finishing something.

I tend to start lots of little projects -- an interesting question pops into my head, and I spend an hour banging out some prototype code, and then it sits collecting dust somewhere in `~/dev`. I decided it was about time that I actually took something all the way through to a finished application that other people can use, mostly to prove to myself that I can do it.

I also have really fond memories of using PINE to read email when I got my first email address back in 1993, and I've always wanted an excuse to make a console application that pays tribute to it.

## Contributing

1. [Fork it](http://github.com/stewartmjohnson/gaman/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

* [Stewart M. Johnson](http://www.bolidian.com/)
