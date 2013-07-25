# --                                                            ; {{{1
#
# File        : napp/cmds/new.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-25
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Cmds; module New

  USAGE   = 'napp new <name> <type> <repo> [<opt(s)>]'
  HELP    = 'napp help new [<type>]'

  # --

  # parse opts, validate; MODIFIES cfg -> done
  def self.prepare!(cfg, args_)                                 # {{{1
    name_, type, repo, *args = OU::Valid.args 'new', args_, 3, nil
    Valid.type! type; Valid.repo! repo; t = Type.get type
    cfg.name = Cfg.app_name name_
    cfg.extra = Cfg::Extra.build(type: type, type_mod: t) do |extra|
      cfg.app = Cfg::App.build(
        type: type, repo: repo,
        vcs: cfg.global.defaults['app']['vcs'],
        branch: cfg.global.defaults['app']['branch']
      ) do |app|
        cfg.type = t::TypeCfg.build(t::DEFAULTS) do |c_t|
          op = opt_parser cfg, app, c_t, extra
          as = op.parse_r args
          as.empty? or raise OU::Valid::ArgumentError,
            'too many arguments'
          Valid.vcs! app.vcs; Valid.branch! app.branch
          extra.vcs_mod = VCS.get app.vcs
          t.prepare! cfg, c_t
        end .check!
      end .check!
    end .check!
    cfg.freeze.check!
    nil
  end                                                           # }}}1

  # create new app: clone + cfg
  def self.run(cfg, *args_)                                     # {{{1
    prepare! cfg, args_; name = cfg.name.join; app = cfg.app
    cfg.logger["creating `#{name}' ..."]
    OU.odie! "app `#{name}' already exists", log: cfg.logger \
      if OU::FS.exists? Cfg.dir_app(cfg)
    OU.onow 'Adding new app', name
    OU::FS.omkdir_p Cfg.dirs_app(cfg)
    cfg.extra.vcs_mod.clone app.repo, Cfg.dir_app_app(cfg), app.branch
    OU.onow 'Saving', *%w{ app.yml type.yml }
    Cfg.save_app cfg; Cfg.save_type cfg
    OU.onow 'Done.'
    cfg.logger["`#{name}' created."]
  end                                                           # }}}1

  # help message; MODIFIES cfg
  def self.help(cfg, *args_)                                    # {{{1
    type,     = OU::Valid.args 'help new', args_, 0, 1
    Valid.type! type if type
    t         = type && Type.get(type)
    extra = Cfg::Extra.new type: type, type_mod: t  # incomplete
    "Usage: #{ USAGE }\n\n" +
    opt_parser(cfg, nil, nil, extra).help + "\n" +
    "Types: #{ Type.which.keys.sort*', ' }\n" +
    "VCSs: #{ VCS.which.keys.sort*', ' }\n"
  end                                                           # }}}1

  # option parser; extended by extra.type_mod.options;
  # MODIFIES cfg
  def self.opt_parser(cfg, app, type, extra)                    # {{{1
    # TODO: napp modify --name= --repo= !?
    OU::Opt::Parser.new 'Options:' do |o|
      o.on('--vcs VCS',
           'Version control system; ' +
           "default is #{cfg.global.defaults['vcs']}") do |x|
        app.vcs = x
      end
      o.on('--branch BRANCH',
           'VCS branch; default is ' +
           "#{cfg.global.defaults['branch']}") do |x|
        app.branch = x
      end
      if t = extra.type_mod
        o.separator "\n#{extra.type} options:"
        t.options o, cfg, type
      else
        o.separator "\nTo see type options, use: #{HELP}"
      end
    end
  end                                                           # }}}1

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
