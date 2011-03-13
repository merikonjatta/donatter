require 'rubygems'
require 'daemons'

Daemons.run(File.join(File.expand_path(File.dirname(__FILE__)), 'collector_server.rb'))
