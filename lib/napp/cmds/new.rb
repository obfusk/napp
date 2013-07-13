# --                                                            ; {{{1
#
# File        : napp/cmds/new.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-13
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/cfg'
require 'napp/type'
require 'napp/util'
require 'napp/valid'
require 'napp/vcs'

module Napp; module Cmds; module New

  USAGE   = 'napp new <name> <type> <repo> [<opt(s)>]'
  HELP    = 'napp help new [<type>]'

  CmdCfg  = Util.struct *%w{ help }

  # --

  # parse opts, validate; MODIFIES cfg
  def self.prepare(cfg, name_, type, repo, args)                # {{{1
    Valid.type! type; Valid.repo! repo
    name  = Cfg.app_name name_
    t     = Type.get type
    cmd   = CmdCfg.new help: false
    app   = Cfg::App.new type: type, repo: repo,
              vcs: cfg.global.defaults['vcs'],
              branch: cfg.global.defaults['branch']
    extra = Cfg::Extra.new type: type, type_mod: t
    cfg.cmd = cmd; cfg.name = name; cfg.app = app; cfg.extra = extra
    op    = opt_parser cfg
    as    = Util.parse_opts op, args
    as.empty? or raise Util::ArgError, 'too many arguments'
    cfg.extra.vcs_mod = VCS.get cfg.app.vcs
    t.validate! cfg
    nil
  end                                                           # }}}1

  # ... TODO ...
  def self.run(cfg, *args_)                                     # {{{1
    name, type, repo, *args = Util.args 'new', args_, 3, nil
    prepare cfg, name, type, repo, args

    require 'pry'; binding.pry                                  # TODO
  end                                                           # }}}1

  # help message; MODIFIES cfg
  def self.help(cfg, *args_)                                    # {{{1
    type,     = Util.args 'help new', args_, 0, 1
    Valid.type! type if type
    t         = type && Type.get(type)
    cfg.cmd   = CmdCfg.new help: true
    cfg.extra = Cfg::Extra.new type: type, type_mod: t
    "Usage: #{ USAGE }\n\n" +
    opt_parser(cfg).help + "\n" +
    "Types: #{ Type.which.keys.sort.join ', ' }\n" +
    "VCSs: #{ VCS.which.keys.sort.join ', ' }\n"
  end                                                           # }}}1

  # option parser; extended by cfg.extra.type_mod.options;
  # MODIFIES cfg
  def self.opt_parser(cfg)                                      # {{{1
    # TODO: napp modify --name= --repo= !?
    OptionParser.new 'Options:' do |o|
      o.on('--vcs VCS',
           'Version control system; ' +
           "default is #{cfg.global.defaults['vcs']}") do |x|
        cfg.app.vcs = x
      end
      o.on('--branch BRANCH',
           'VCS branch; default is ' +
           "#{cfg.global.defaults['branch']}") do |x|
        cfg.app.branch = x
      end
      if t = cfg.extra.type_mod
        o.separator "\n#{cfg.extra.type} options:"
        t.options o, cfg
      else
        o.separator "\nTo see type options, use: #{HELP}"
      end
    end
  end                                                           # }}}1

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
