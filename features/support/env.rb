# --                                                            ; {{{1
#
# File        : features/support/env.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-30
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

$:.unshift File.expand_path('../../../test/lib', __FILE__)

require 'napp/spec/helper'
require 'napp/spec/sandbox'

require 'aruba/cucumber'

# --

Before('@slow') do
  @aruba_timeout_seconds = 10
end

Before('@sandbox') do
  @sandbox = Napp__Spec::Sandbox.new
  @sandbox.setup; @sandbox.set_env
  puts "[sandbox #{@sandbox.dir_sandbox :abs}]"
end

After('@sandbox') do
  @sandbox.teardown unless ENV['KEEP_SANDBOX'] == 'yes'
  @sandbox.restore_env
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
