# --                                                            ; {{{1
#
# File        : napp/cmds/status.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-22
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Cmds; module Status

  USAGE = 'napp status <name> [<opt(s)>]'

  DEFAULTS = { how: :verbose }

  # --

  # parse opts; MODIFIES cfg -> done
  def self.prepare!(cfg, args_)                                 # {{{1
    name_, *args = OU::Valid.args 'status', args_, 1, nil
    Cfg.load_app_config cfg, name_; opts = DEFAULTS.dup
    op = opt_parser opts; as = op.parse_r args
    as.empty? or raise OU::Valid::ArgumentError, 'too many arguments'
    opts
  end                                                           # }}}1

  # show app status
  def self.run(cfg, *args_)
    opts = prepare! cfg, args_; name = cfg.name.join
    OU.onow 'App', name if opts[:how] == :verbose
    cfg.extra.type_mod.status cfg, opts[:how]
  end

  # help message
  def self.help(cfg, *args_)
    OU::Valid.args 'help status', args_, 0
    "Usage: #{ USAGE }\n\n" + opt_parser(nil).help
  end

  # option parser
  def self.opt_parser(opts)                                     # {{{1
    OU::Opt::Parser.new 'Options:' do |o|
      o.on('--quiet', 'Quiet output: just (coloured) status') do
        opts[:how] = :quiet
      end
      o.on('--short',
           'Short output: (coloured) status + extra info') do
        opts[:how] = :short
      end
      o.on('--verbose', 'Verbose output (default)') do
        opts[:how] = :verbose
      end
    end
  end                                                           # }}}1

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
