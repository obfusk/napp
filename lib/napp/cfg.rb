# --                                                            ; {{{1
#
# File        : napp/cfg.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-13
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/type'
require 'napp/util'
require 'napp/valid'
require 'napp/vcs'

require 'yaml'

module Napp; module Cfg

  DEFAULT_NAPPCFG = '/etc/napp'

  # --

  All     = Util.struct *%w{ nappcfg global cmd name app type extra }
  Global  = Util.struct *%w{ dirs user user_prefix users log_w_sudo
                             commands defaults }
  Name    = Util.struct *%w{ user app }
  App     = Util.struct *%w{ type repo vcs branch }
  Extra   = Util.struct *%w{ type type_mod vcs_mod }
  Dirs    = Util.struct *%w{ apps log app }
  AppDirs = Util.struct *%w{ app cfg log run }

  # --

  # ENV['NAPPCFG'] if set and not empty, DEFAULT_NAPPCFG otherwise
  def self.nappcfg
    env = ENV['NAPPCFG']
    dir = (env && !env.empty?) ? env : DEFAULT_NAPPCFG
  end

  # --

  # app name (where foo is expanded to <user>/foo) -> Name
  # @raise ValidationError if not word or word1/word2
  def self.app_name(name)                                       # {{{1
    x = if name.match %r{^(#{Valid::WORD})$}
      { user: Util.user, app: name }
    elsif name.match %r{^(#{Valid::WORD})/(#{Valid::WORD})$}
      { user: $1, app: $2 }
    else
      Util.invalid! 'invalid name'
    end
    Name.new x
  end                                                           # }}}1

  # --

  # app dir
  def self.dir_app(cfg)
    h = Util.home cfg.name.user
    "#{h}/#{cfg.global.dirs.apps}/#{cfg.name.app}"
  end

  def self.dir_app_app(cfg)
    "#{dir_app cfg}/#{cfg.global.dirs.app.app}"
  end

  def self.dir_app_cfg(cfg)
    "#{dir_app cfg}/#{cfg.global.dirs.app.cfg}"
  end

  def self.dir_app_log(cfg)
    "#{dir_app cfg}/#{cfg.global.dirs.app.log}"
  end

  def self.dir_app_run(cfg)
    "#{dir_app cfg}/#{cfg.global.dirs.app.run}"
  end

  # --

  # napp.yml path
  def self.file_napp_yml(cfg)
    "#{cfg.nappcfg}/napp.yml"
  end

  # app.yml path
  def self.file_app_cfg_app(cfg)
    "#{dir_app_cfg cfg}/app.yml"
  end

  # type.yml path
  def self.file_app_cfg_type(cfg)
    "#{dir_app_cfg cfg}/type.yml"
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
    dirs[:app]      = AppDirs.new app
    napp[:dirs]     = Dirs.new dirs
    napp[:commands] = d['commands']
    napp[:defaults] = d['defaults']
    Global.new napp
  end                                                           # }}}1

  # load Global from napp.yml
  def self.read_global(cfg)
    load_global File.read file_napp_yml cfg
  end

  # --

  # load App from YAML string
  def self.load_app(cfg, str)
    App.new YAML.load str
  end

  # load App from YAML app cfg file
  def self.read_app(cfg)
    load_app cfg, File.read(file_app_cfg_app(cfg))
  end

  # dump App to YAML string
  def self.dump_app(cfg)
    YAML.dump cfg.app.to_h
  end

  # dump App to YAML app cfg file
  def self.save_app(cfg, app)
    File.write file_app_cfg_app(cfg), dump_app(app)
  end

  # --

  # load type from YAML string
  def self.load_type(cfg, str)
    cfg.extra.type_mod::TypeCfg.new YAML.load str
  end

  # load type from app cfg file
  def self.read_type(cfg)
    load_type cfg, File.read(file_app_cfg_type(cfg))
  end

  # dump type to YAML string
  def self.dump_type(cfg)
    YAML.dump cfg.type.to_h
  end

  # dump type to YAML app cfg file
  def self.save_type(cfg, type)
    File.write file_app_cfg_type(cfg), dump_type(type)
  end

  # --

  # App -> Extra
  def self.app_to_extra(app)
    Cfg::Extra.new type: app.type, type_mod: Type.get(app.type),
      vcs_mod: VCS.get(app.vcs)
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
