#!/usr/bin/ruby
#

require 'travis'

repo = Travis::Repository.find('mozilla-b2g/gaia')
repo.builds(:event_type => 'pull_request')
  .take_while { |b| b.pending? }
  .group_by { |b| b.pull_request_number }
  .each {
    |_, b|
    b.drop(1)
      .each { |b| b.cancel }
  }

