# --                                                            ; {{{1
#
# File        : napp/cmd.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-28
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp

  module Cmds; end

  OU.require_all 'napp/cmds'

  module Cmd

    USAGE = \
      'napp { <command> [<arg(s)>] | help [<command>] | version }'

    # --

    # run/dispatch; input error -> udie!; sys error -> odie
    def self.run(cfg, *args)                                    # {{{1
      begin
        run_cmd cfg, *args
      rescue OU::Valid::ArgumentError, OU::Valid::ValidationError,
             OptionParser::ParseError => e
        OU.udie! USAGE, e.message
      rescue OU::RunError => e
        OU.odie! e.message, log: cfg.logger
      end
    end                                                         # }}}1

    # help message
    def self.help(cfg)
      "Usage: #{ USAGE }\n\n" +
      "Commands: #{ which.keys.sort*', ' }\n"
    end

    # --

    # dispatch to cmd submodule run; MODIFIES cfg[:help]
    # @raise ArgError on unknown command
    def self.run_cmd(cfg, cmd = nil, *args)                     # {{{1
      if !cmd
        cfg.other[:help] = true
        puts "Usage: #{USAGE}"
      elsif cmd == 'version'
        cfg.other[:help] = true
        puts "napp version #{Napp::VERSION}"
      elsif cmd == 'help'
        run_help cfg, *args
      elsif c = which[cmd]
        c.run cfg, *args
      else
        raise OU::Valid::ArgumentError, "no such subcommand: #{cmd}"
      end
    end                                                         # }}}1

    # dispatch to cmd submodule help; MODIFIES cfg[:help]
    # @raise ArgError on unknown command
    def self.run_help(cfg, cmd = nil, *args)                    # {{{1
      cfg.other[:help] = true
      if !cmd
        puts help cfg
      elsif c = which[cmd]
        puts c.help cfg, *args
      else
        raise OU::Valid::ArgumentError, "no such subcommand: #{cmd}"
      end
    end                                                         # }}}1

    # --

    # cmd submodules
    def self.which
      OU.submodules Napp::Cmds
    end

  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
