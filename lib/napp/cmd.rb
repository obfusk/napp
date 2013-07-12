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

module Napp

  module Cmds; end

  Util.require_all 'napp/cmds'

  module Cmd

    USAGE = 'napp { <command> [<arg(s)>] | help [<command>] }'

    # --

    # run/dispatch; ArgumentError -> die!
    def self.run(*args)                                         # {{{1
      begin
        run_cmd *args
      rescue ArgumentError => e
        Util.fail! USAGE, e.message
      end
    end                                                         # }}}1

    # help message
    def self.help                                               # {{{1
      puts <<-END .gsub(/^ {8}/, '')
        Usage     : #{ USAGE }
        Commands  : #{ which.keys.sort.join ', ' }
      END
    end                                                         # }}}1

    # --

    # dispatch to cmd submodule run
    def self.run_cmd(cmd = nil, *args)                          # {{{1
      if !cmd
        puts "Usage: #{USAGE}"
      elsif cmd == 'help'
        run_help(*args)
      elsif c = which[cmd]
        c.run *args
      else
        raise ArgumentError, "no such subcommand: #{cmd}"
      end
    end                                                         # }}}1

    # dispatch to cmd submodule help
    def self.run_help(cmd = nil)                                # {{{1
      if !cmd
        help
      elsif c = which[cmd]
        c.help
      else
        raise ArgumentError, "no such subcommand: #{cmd}"
      end
    end                                                         # }}}1

    # --

    # cmd submodules
    def self.which
      Util.submodules Napp::Cmds
    end

  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
