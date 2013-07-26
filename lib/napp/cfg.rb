# --                                                            ; {{{1
#
# File        : napp/cfg.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-26
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/util' # first!

require 'napp/log'
require 'napp/valid'
require 'napp/version'

require 'napp/type'
require 'napp/vcs'

require 'yaml'

module Napp; module Cfg

  DEFAULT_NAPPCFG = '/etc/napp'

  # --

  Global  = OU.struct(*%w{ dirs user users log_w_sudo commands
                           defaults logfiles })
  App     = OU.struct(*%w{ type repo vcs branch })
  Extra   = OU.struct(*%w{ type type_mod vcs_mod })
  Dirs    = OU.struct(*%w{ apps log nginx app })
  AppDirs = OU.struct(*%w{ app cfg log run })

  # --

  All = OU.struct(*%w{ nappcfg global log other
                       name app type extra }) do                # {{{1
    # pass self to self.log
    def logger
      self.log[self]
    end
  end                                                           # }}}1

  Name = OU.struct(*%w{ user app }) do                          # {{{1
    # join: user+sep+app
    def join(sep = '/')
      "#{user}#{sep}#{app}"
    end
    # safe join
    def safe
      "#{user.downcase}_S_#{app.downcase}".gsub('-', '_D_')
    end
  end                                                           # }}}1

  # --

  # create Cfg::All; sets nappcfg, global, log, other if not specified
  def self.config(h = {}, &b)                                   # {{{1
    x = All.build(h) do |cfg|
      cfg.nappcfg ||= nappcfg
      cfg.global  ||= read_global cfg
      cfg.log     ||= ->(c) { ->(*msgs) { Log.log c, *msgs } }
      cfg.other   ||= {}
      b[cfg] if b
      cfg.other.freeze
    end
    x.other[:help] ? x : x.check!
  end                                                           # }}}1

  # set name; check exists; load app, extra, type; freeze; check!
  def self.load_app_config(cfg, name)                           # {{{1
    cfg.name  = app_name name
    OU.odie! "app `#{cfg.name.join}' does not exist",
      log: cfg.logger unless OU::FS.exists? Cfg.dir_app(cfg)
    cfg.app   = read_app cfg
    cfg.extra = app_to_extra cfg.app
    cfg.type  = read_type cfg
    cfg.freeze.check!
  end                                                           # }}}1

  # --

  # ENV['NAPPCFG'] if set and not empty, DEFAULT_NAPPCFG otherwise
  def self.nappcfg
    OU.empty_as_nil(ENV['NAPPCFG']) || DEFAULT_NAPPCFG
  end

  # --

  # app name (where foo is expanded to <user>/foo) -> Name
  # @raise ValidationError if not word or word1/word2
  def self.app_name(name)                                       # {{{1
    x = if name.match %r{^(#{Valid::WORD})$}
      { user: OU::OS.user, app: name }
    elsif name.match %r{^(#{Valid::WORD})/(#{Valid::WORD})$}
      { user: $1, app: $2 }
    else
      OU::Valid.invalid! 'invalid name'
    end
    Name.build(x).check!
  end                                                           # }}}1

  # --

  # app dirs
  def self.dirs_app(cfg)
    %w{ dir_app dir_app_app dir_app_cfg dir_app_log dir_app_run } \
      .map { |x| send x, cfg }
  end

  # app dir
  def self.dir_app(cfg, *paths)
    ([OU::OS.home(cfg.name.user), cfg.global.dirs.apps,
      cfg.name.app] + paths)*'/'
  end

  # --

  # run block in app's app dir
  def self.in_app_app(cfg, &b)
    Dir.chdir dir_app_app(cfg), &b
  end

  # --

  # $APP/$app
  def self.dir_app_app(cfg, *paths)
    dir_app cfg, cfg.global.dirs.app.app, *paths
  end

  # $APP/$cfg
  def self.dir_app_cfg(cfg, *paths)
    dir_app cfg, cfg.global.dirs.app.cfg, *paths
  end

  # $APP/$log
  def self.dir_app_log(cfg, *paths)
    dir_app cfg, cfg.global.dirs.app.log, *paths
  end

  # $APP/$run
  def self.dir_app_run(cfg, *paths)
    dir_app cfg, cfg.global.dirs.app.run, *paths
  end

  # --

  # napp.yml path
  def self.file_napp_yml(cfg)
    "#{cfg.nappcfg}/napp.yml"
  end

  # global napp.log path
  def self.file_log(cfg)
    "#{cfg.global.dirs.log}/napp.log"
  end

  # global nginx config dir path
  def self.dir_nginx(cfg, *paths)
    p = cfg.global.dirs.nginx; abs = Pathname.new(p).absolute?
    ((abs ? [p] : [cfg.nappcfg, p]) + paths)*'/'
  end

  # --

  # app.yml path
  def self.file_app_cfg_app(cfg)
    dir_app_cfg cfg, 'app.yml'
  end

  # type.yml path
  def self.file_app_cfg_type(cfg)
    dir_app_cfg cfg, 'type.yml'
  end

  # napp.log path
  def self.file_app_log(cfg)
    dir_app_log cfg, 'napp.log'
  end

  # daemon.stat path
  def self.file_app_stat(cfg)
    dir_app_run cfg, 'daemon.stat'
  end

  # daemon.sock path
  def self.file_app_sock(cfg)
    dir_app_run cfg, 'daemon.sock'
  end

  # --

  # load Global from YAML string
  def self.load_global(str)                                     # {{{1
    d     = YAML.load str
    napp  = Hash[ (Global.members - [:dirs, :commands, :defaults])
                  .map { |x| [x, d['napp'][x.to_s]] } ]
    dirs  = Hash[ (Dirs.members - [:app])
                  .map { |x| [x, d['napp']['dirs'][x.to_s]] } ]
    app   = Hash[ AppDirs.members
                  .map { |x| [x, d['napp']['dirs']['app'][x.to_s]] } ]
    dirs[:app]      = AppDirs.build(app).check!
    napp[:dirs]     = Dirs.build(dirs).check!
    napp[:commands] = d['commands'].freeze
    napp[:defaults] = d['defaults'].freeze
    napp[:logfiles] = []
    Global.build(napp).check!
  end                                                           # }}}1

  # load Global from napp.yml
  def self.read_global(cfg)
    load_global File.read file_napp_yml cfg
  end

  # --

  # load App from YAML string
  def self.load_app(cfg, str)
    App.build(YAML.load str).check!
  end

  # load App from YAML app cfg file
  def self.read_app(cfg)
    load_app cfg, File.read(file_app_cfg_app(cfg))
  end

  # dump App to YAML string
  def self.dump_app(cfg)
    YAML.dump cfg.app.to_str_h
  end

  # dump App to YAML app cfg file
  def self.save_app(cfg)
    File.write file_app_cfg_app(cfg), dump_app(cfg)
  end

  # --

  # load type from YAML string
  def self.load_type(cfg, str)
    cfg.extra.type_mod::TypeCfg.build(YAML.load str) do |t|
      t.load
    end .check!
  end

  # load type from app cfg file
  def self.read_type(cfg)
    load_type cfg, File.read(file_app_cfg_type(cfg))
  end

  # dump type to YAML string
  def self.dump_type(cfg)
    YAML.dump cfg.type.dump
  end

  # dump type to YAML app cfg file
  def self.save_type(cfg)
    File.write file_app_cfg_type(cfg), dump_type(cfg)
  end

  # --

  # App -> Extra
  def self.app_to_extra(app)
    Extra.build(type: app.type, type_mod: Type.get(app.type),
      vcs_mod: VCS.get(app.vcs)).check!
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
