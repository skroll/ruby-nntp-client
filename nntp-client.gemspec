# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nntp/client/version'

Gem::Specification.new do |gem|
  gem.name          = 'nntp-client'
  gem.version       = NNTP::Client::VERSION
  gem.authors       = ['Scott M. Kroll']
  gem.email         = ['skroll@gmail.com']
  gem.description   = %q{A simple NNTP client library}
  gem.summary       = %q{A simple NNTP client library}
  gem.homepage      = ""
  gem.has_rdoc      = true
  gem.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'NNTP-Client', '--main', 'README.rdoc']
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency 'buffered_io', '~> 0.0.1'
end

