# --                                                            ; {{{1
#
# File        : napp/cmds/new.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-16
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

  # --

  # parse opts, validate; MODIFIES cfg
  def self.prepare!(cfg, args_)                                 # {{{1
    name_, type, repo, *args = OU::Valid.args 'new', args_, 3, nil
    Valid.type! type; Valid.repo! repo
    name  = Cfg.app_name name_
    t     = Type.get type
    app   = Cfg::App.mnew type: type, repo: repo,
              vcs: cfg.global.defaults['app']['vcs'],
              branch: cfg.global.defaults['app']['branch']
    extra = Cfg::Extra.new type: type, type_mod: t
    cfg.name = name; cfg.app = app; cfg.extra = extra
    cfg.other[:cmd_help] = false
    op    = opt_parser cfg
    as    = OU::Valid.parse_opts op, args
    as.empty? or raise OU::Valid::ArgumentError, 'too many arguments'
    Valid.vcs! cfg.app.vcs; Valid.branch! cfg.app.branch
    cfg.extra.vcs_mod = VCS.get cfg.app.vcs
    t.prepare! cfg
  end                                                           # }}}1

  # create new app: clone + cfg
  def self.run(cfg, *args_)                                     # {{{1
    prepare! cfg, args_; name = cfg.name.join; app = cfg.app
    # TODO {
    if ENV['DEBUG_PRY'] == 'yes' then require 'pry'; binding.pry end
    # } TODO
    Log.olog cfg, "creating `#{name}' ..."
    OU.odie! "app `#{name}' already exists", log: cfg.logger \
      if OU::FS.exists? Cfg.dir_app(cfg)
    OU.onow 'Adding new app', name
    OU.omkdir_p Cfg.dirs_app(cfg)
    cfg.extra.vcs_mod.clone app.repo, Cfg.dir_app_app(cfg), app.branch
    OU.onow 'Saving', *%w{ app.yml type.yml }
    Cfg.save_app cfg; Cfg.save_type cfg
    OU.onow 'Done.'
    Log.olog cfg, "`#{name}' created."
  end                                                           # }}}1

  # help message; MODIFIES cfg
  def self.help(cfg, *args_)                                    # {{{1
    type,     = OU::Valid.args 'help new', args_, 0, 1
    Valid.type! type if type
    t         = type && Type.get(type)
    cfg.extra = Cfg::Extra.new type: type, type_mod: t
    cfg.other[:cmd_help] = true
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
