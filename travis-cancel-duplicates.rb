#!/usr/bin/ruby
#

require 'travis'

print('Travis token (run `travis token` to get it): ')
Travis.access_token = gets.chomp
puts "Logging in..."
puts "Hello #{Travis::User.current.name}!"

puts "Finding repository mozilla-b2g/gaia"
repo = Travis::Repository.find('mozilla-b2g/gaia')

repo.builds(:event_type => 'pull_request')
  .take_while { |b| !b.passed? }
  .group_by { |b| b.pull_request_number }
  .each {
    |_, b|
    b.drop(1)
     .select { |b| b.pending? }
     .each { |b| p "Canceling #{b.number}"; b.cancel }
  }

