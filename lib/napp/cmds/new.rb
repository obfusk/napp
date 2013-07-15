# --                                                            ; {{{1
#
# File        : napp/cmds/new.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-15
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/cfg'
require 'napp/log'
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
  def self.prepare(cfg, args_)                                  # {{{1
    name_, type, repo, *args = Util.args 'new', args_, 3, nil
    Valid.type! type; Valid.repo! repo
    name  = Cfg.app_name name_
    t     = Type.get type
    cmd   = CmdCfg.new help: false
    app   = Cfg::App.new type: type, repo: repo,
              vcs: cfg.global.defaults['app']['vcs'],
              branch: cfg.global.defaults['app']['branch']
    extra = Cfg::Extra.new type: type, type_mod: t
    cfg.cmd = cmd; cfg.name = name; cfg.app = app; cfg.extra = extra
    op    = opt_parser cfg
    as    = Util.parse_opts op, args
    as.empty? or raise Util::ArgError, 'too many arguments'
    Valid.vcs! cfg.app.vcs; Valid.branch! cfg.app.branch
    cfg.extra.vcs_mod = VCS.get cfg.app.vcs
    t.validate! cfg
  end                                                           # }}}1

  # create new app: clone + cfg
  def self.run(cfg, *args_)                                     # {{{1
    prepare cfg, args_; name = cfg.name.join; app = cfg.app
    Log.olog cfg, "creating `#{name}' ..."
    Util.odie cfg, "app `#{name}' already exists" \
      if Util.exists? Cfg.dir_app(cfg)
    Util.onow 'Adding new app', name
    Util.mkdir_p Cfg.dirs_app(cfg)
    cfg.extra.vcs_mod.clone app.repo, Cfg.dir_app_app(cfg), app.branch
    Util.onow 'Saving', *%w{ app.yml type.yml }
    Cfg.save_app cfg; Cfg.save_type cfg
    Util.onow 'Done.'
    Log.olog cfg, "`#{name}' created."
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
    "Types: #{ Type.which.keys.sort*', ' }\n" +
    "VCSs: #{ VCS.which.keys.sort*', ' }\n"
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
