# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nanny/version'

Gem::Specification.new do |gem|
  gem.name          = "nanny"
  gem.version       = Nanny::VERSION
  gem.authors       = ["Stefano Verna"]
  gem.email         = ["stefano.verna@welaika.com"]
  gem.description   = %q{Nanny helps you find valid Torrent links from CLI}
  gem.summary       = %q{Nanny scrapes torrent meta-search engines to find direct torrent links}
  gem.homepage      = "http://getmetorrents.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "nokogiri"
  gem.add_dependency "addressable"
  gem.add_dependency "active_support"
  gem.add_dependency "rest-client"
  gem.add_dependency "colored"
  gem.add_dependency "trollop"
  gem.add_dependency "terminal-table"
  gem.add_dependency "highline"
  gem.add_dependency "ruby-progressbar"
end
