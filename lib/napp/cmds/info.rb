# --                                                            ; {{{1
#
# File        : napp/cmds/info.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-01
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'json'
require 'yaml'

module Napp; module Cmds; module Info

  USAGE = 'napp info <name> [<opt(s)>]'

  DEFAULTS = { how: :human, width: 29 }

  # --

  # parse opts; MODIFIES cfg -> done
  def self.prepare!(cfg, args_)                                 # {{{1
    name_, *args = OU::Valid.args 'info', args_, 1, nil
    Cfg.load_app_config cfg, name_; opts = DEFAULTS.dup
    op = opt_parser opts; as = op.parse_r args
    as.empty? or raise OU::Valid::ArgumentError, 'too many arguments'
    opts
  end                                                           # }}}1

  # show app info
  def self.run(cfg, *args_)                                     # {{{1
    opts = prepare! cfg, args_; name = cfg.name.join
    a = Cfg.app_to_hash cfg; t = Cfg.type_to_hash cfg
    i = { 'name' => name, 'app' => a, 'type' => t }
    case opts[:how]
    when :human ; puts Util.pretty_config(i, width: opts[:width])
    when :json  ; puts JSON.pretty_generate(i)
    when :yaml  ; puts i.to_yaml
    else        ; raise '[WTF!?] case did not match'
    end
  end                                                           # }}}1

  # help message
  def self.help(cfg, *args_)
    OU::Valid.args 'help info', args_, 0
    "Usage: #{ USAGE }\n\n" + opt_parser(nil).help
  end

  # option parser
  def self.opt_parser(opts)                                     # {{{1
    OU::Opt::Parser.new 'Options:' do |o|
      o.on('-h', '--human', 'Human-readable (the default)') do
        opts[:how] = :human
      end
      o.on('-j', '--json', 'JSON') do
        opts[:how] = :json
      end
      o.on('-y', '--yaml', 'YAML') do
        opts[:how] = :yaml
      end
      o.on('-w', '--width COLS', Integer,
           'Key width; only for --human; ' +
           "default is #{DEFAULTS[:width]}") do |x|
        opts[:width] = x
      end
    end
  end                                                           # }}}1

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
