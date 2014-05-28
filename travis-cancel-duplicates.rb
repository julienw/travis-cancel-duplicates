#!/usr/bin/ruby
#

require 'travis'

def get_builds(repo, after_number = nil)
  args = { :event_type => 'pull_request' }
  args[:after_number] = after_number if after_number

  builds = repo.builds(args)
  pendingBuilds = builds.take_while { |b| !b.passed? }.to_a
  pendingBuilds.concat(get_builds(repo, builds.last.number)) if builds.length > 0 && pendingBuilds.length == builds.length
  return pendingBuilds
end

print('Travis token (run `travis token` to get it): ')
Travis.access_token = gets.chomp
puts "Logging in..."
puts "Hello #{Travis::User.current.name}!"

puts "Finding repository mozilla-b2g/gaia"
repo = Travis::Repository.find('mozilla-b2g/gaia')

get_builds(repo).group_by { |b| b.pull_request_number }
  .each {
    |_, b|
    b.drop(1)
     .select { |b| b.pending? }
     .each { |b| p "Canceling #{b.number}"; b.cancel }
  }

