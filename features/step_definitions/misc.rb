# --                                                            ; {{{1
#
# File        : features/_steps/misc.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-31
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

When(/^I run `([^`]*)` with:$/) do |cmd,opts|
  run_simple unescape(([cmd] + opts.raw.flatten)*' '), false
end

When(/^I run `([^`]*)` with bash$/) do |cmd|
  run_simple "bash -c \"#{cmd}\"", false
end

When(/^I sleep (\d+) seconds?$/) do |secs|
  sleep secs.to_i
end

Then(/^it should succeed$/) do
  assert_success true
end

Then(/^it should fail$/) do
  assert_success false
end

Then(/^the last stdout should be:$/) do |expected|
  assert_exact_output expected, last_process.stdout
end

Then(/^the last stderr should be:$/) do |expected|
  assert_exact_output expected, last_process.stderr
end

Then(/^the last stdout should match:$/) do |expected|
  assert_matching_output expected, last_process.stdout
end

Then(/^the last stderr should match:$/) do |expected|
  assert_matching_output expected, last_process.stderr
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
