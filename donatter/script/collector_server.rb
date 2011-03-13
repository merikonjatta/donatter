#!/usr/bin/env ruby

# Load rails environment
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

puts "Rails environment loaded."
require 'twitter_stream_relay_server'


track_words = [
  'donate',
  'donation',
  'donated',
  '寄付',
  '募金',
  '義援金',
]
TwitterStreamRelayServer.new(track_words).start
