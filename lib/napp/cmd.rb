# --                                                            ; {{{1
#
# File        : napp/cmd.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-13
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
    def self.run(cfg, *args)                                    # {{{1
      begin
        run_cmd cfg, *args
      rescue Util::ArgError, Util::ValidationError,
             OptionParser::ParseError => e
        Util.fail! USAGE, e.message
      end
    end                                                         # }}}1

    # help message
    def self.help(cfg)
      "Usage: #{ USAGE }\n\n" +
      "Commands: #{ which.keys.sort.join ', ' }\n"
    end

    # --

    # dispatch to cmd submodule run
    def self.run_cmd(cfg, cmd = nil, *args)                     # {{{1
      if !cmd
        puts "Usage: #{USAGE}"
      elsif cmd == 'help'
        run_help cfg, *args
      elsif c = which[cmd]
        c.run cfg, *args
      else
        raise Util::ArgError, "no such subcommand: #{cmd}"
      end
    end                                                         # }}}1

    # dispatch to cmd submodule help
    def self.run_help(cfg, cmd = nil, *args)                    # {{{1
      if !cmd
        puts help cfg
      elsif c = which[cmd]
        puts c.help cfg, *args
      else
        raise Util::ArgError, "no such subcommand: #{cmd}"
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
