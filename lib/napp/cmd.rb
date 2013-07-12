# --                                                            ; {{{1
#
# File        : napp/cmd.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-12
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/util'

module Napp; module Cmd

  # run/dispatch; ArgumentError -> die!
  def self.run(cmd, *args)                                      # {{{1
    begin
      run_cmd cmd, *args
    rescue ArgumentError => e
      Util.die! "Error: #{e.message}"
    end
  end                                                           # }}}1

  # dispatch to cmd submodule run
  def self.run_cmd(cmd, *args)                                  # {{{1
    if !cmd
      raise ArgumentError, 'subcommand expected'
    elsif cmd == 'help'
      run_help(*args)
    elsif c = which[cmd]
      c.run *args
    else
      raise ArgumentError, "no such subcommand: #{cmd}"
    end
  end                                                           # }}}1

  # dispatch to cmd submodule help
  def run_help(cmd)                                             # {{{1
    if !cmd
      raise ArgumentError, 'subcommand expected'
    elsif c = which[cmd]
      c.help
    else
      raise ArgumentError, "no such subcommand: #{cmd}"
    end
  end                                                           # }}}1

  # --

  # cmd submodules
  def self.which
    Util.submodules Napp::Cmds
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
