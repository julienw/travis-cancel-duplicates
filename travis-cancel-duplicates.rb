#!/usr/bin/ruby
#

require 'travis'
require 'yaml'

OUR_REPOSITORY = "mozilla-b2g/gaia"

class TravisConfig
  attr_reader :endpoint, :token

  @@TRAVIS_CONFIG_FILE = "#{ENV['HOME']}/.travis/config.yml"
  @@DEFAULT_ENDPOINT = "https://api.travis-ci.org/"

  def initialize()
    puts "Using configuration file #{@@TRAVIS_CONFIG_FILE}"
    @config = YAML.load_file(@@TRAVIS_CONFIG_FILE)
    begin
      @endpoint = @config['repos'][OUR_REPOSITORY]['endpoint']
    rescue
      @endpoint = @@DEFAULT_ENDPOINT
    end

    puts "Found access_token for #{@endpoint}"
    @token = @config['endpoints'][@endpoint]['access_token']
  end
end

def get_builds(repo, after_number = nil)
  args = { :event_type => 'pull_request' }
  args[:after_number] = after_number if after_number

  builds = repo.builds(args)
  pendingBuilds = builds.take_while { |b| !b.passed? }.to_a
  pendingBuilds.concat(get_builds(repo, builds.last.number)) if builds.length > 0 && pendingBuilds.length == builds.length
  return pendingBuilds
end

begin
  config = TravisConfig.new
rescue Exception => e
  puts "Error while login, you probably have no access token, please use `travis login` to login"
  raise e
  exit 1
end

Travis.access_token = config.token
puts "Logging in to #{config.endpoint}..."
puts "Hello #{Travis::User.current.name}!"

puts "Finding repository #{OUR_REPOSITORY}"
repo = Travis::Repository.find(OUR_REPOSITORY)

get_builds(repo).group_by { |b| b.pull_request_number }
  .each {
    |_, b|
    b.drop(1)
     .select { |b| b.pending? }
     .each { |b| p "Canceling #{b.number}"; b.cancel }
  }

