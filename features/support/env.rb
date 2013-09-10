# --                                                            ; {{{1
#
# File        : features/support/env.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-09-10
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

$:.unshift File.expand_path('../../../test/lib', __FILE__)

require 'napp/spec/helper'
require 'napp/spec/sandbox'

require 'aruba/obfusk'

# --

Before do
  process_VERBOSE
end

Before('@slow') do
  @aruba_timeout_seconds = 60
end

Before('@sandbox') do
  @sandbox = Napp__Spec::Sandbox.new
  @sandbox.setup; @sandbox.set_env
  puts "[sandbox #{@sandbox.dir_sandbox :abs}]" if @verbose
end

After('@sandbox') do                                            # {{{1
  begin
    # we must kill any daemons left running by a failed scenario!
    Dir["#{@sandbox.dir_apps :abs}/*/run/daemon.stat"].each do |f|
      d = File.read(f).split
      if d.first == 'running'
        running, daemon_pid, pid = d
        begin
          $stderr.puts "[killing #{daemon_pid}]"
          Process.kill 'TERM', daemon_pid.to_i
        rescue Errno::EPERM, Errno::ESRCH => e
          $stderr.puts e.message
        end
      end
    end
  rescue StandardError => e
    $stderr.puts e.message
    raise e
  ensure
    @sandbox.teardown unless ENV['KEEP_SANDBOX'] == 'yes'
    @sandbox.restore_env
  end
end                                                             # }}}1

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
