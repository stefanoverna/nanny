# Nanny [![Build Status](https://travis-ci.org/stefanoverna/nanny.png?branch=master)](https://travis-ci.org/stefanoverna/nanny)

Nanny is a ruby gem that uses multiple torrent search-engines to find a valid direct
links to torrents. It currently supports Torrentz.eu, Torcache.net and Torrage.com

## Installation

Add this line to your application's Gemfile:

    gem 'nanny'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nanny

## Usage

You can use `nanny` programmatically:

```ruby
require 'nanny'

torrents = Nanny::Search.new.search_torrents("Ubuntu")

torrent.first 
# => <Nanny::Torrent @title="Ubuntu 12 10 Desktop i386", @url="http://torrentz.eu/335990d615594b9be409ccfeb95864e24ec702c7", @seeds=2158, @peers=32, @size=789577728, @hash="335990d615594b9be409ccfeb95864e24ec702c7">

torrent.first.torrent_url 
# => "http://torcache.net/torrent/335990D615594B9BE409CCFEB95864E24EC702C7.torrent"
```

or as a CLI tool:

![cli usage](https://raw.github.com/stefanoverna/nanny/master/doc/cli.png)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
