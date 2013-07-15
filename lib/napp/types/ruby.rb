# --                                                            ; {{{1
#
# File        : napp/types/ruby.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-15
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/daemon'
require 'napp/nginx'
require 'napp/util'

module Napp; module Types; module Ruby

  DEFAULTS = {
    type: 'ruby', listen: nil, port: nil, run: nil, bootstrap: nil,
    update: nil, logdir: nil, public: nil, nginx_server: nil,
    nginx_ssl: nil, nginx_default_server: nil,
    nginx_max_body_size: nil, nginx_proxy_buffering_off: nil
  }

  TypeCfg = Util.struct *DEFAULTS.keys

  # --

  # extends Cmd::New option parser; MODIFIES cfg
  def self.options(o, cfg)                                      # {{{1
    cfg.type  = TypeCfg.new DEFAULTS unless cfg.cmd.help
    d         = cfg.global.defaults['ruby']
    o.on('--socket', 'Listen on socket') do |x|
      cfg.type.listen = :socket
    end
    o.on('--port PORT', 'Listen on port') do |x|
      cfg.type.listen = :port
      cfg.type.port = x
    end
    o.on('--run CMD', 'Command to run app') do |x|
      cfg.type.run = x
    end
    o.on('--bootstrap CMD',
         'Command to bootstrap app;',
         'default is update command') do |x|
      cfg.type.bootstrap = x
    end
    o.on('--update CMD', 'Command to update app') do |x|
      cfg.type.update = x
    end
    o.on('--logdir [DIR]',
         'Subdir of app with *.log files; optional;',
         "default DIR is #{d['logdir']}") do |x|
      cfg.type.logdir = x || d['logdir']
    end
    o.on('--public [DIR]',
         'Subdir of app with public files; optional;',
         "default DIR is #{d['public']}") do |x|
      cfg.type.public = x || d['public']
    end
    Nginx.options(o, cfg)
  end                                                           # }}}1

  # validate type cfg; sets defaults; MODIFIES cfg
  def self.validate!(cfg)                                       # {{{1
    t = cfg.type; t.bootstrap = t.update unless t.bootstrap
    Util.invalid! 'invalid: no socket or port' unless t.listen
    Valid.port! t.port if t.listen == :port
    # NB: nothing to validate for commands except presence
    Util.invalid! 'no run command' unless t.run
    Util.invalid! 'no update command' unless t.update
    Valid.path! 'logdir', t.logdir if t.logdir
    Valid.path! 'public', t.public if t.public
    Nginx.validate! cfg
  end                                                           # }}}1

  # --

  def self.bootstrap(cfg)
  end

  def self.running?(cfg)
  end

  def self.status(cfg)
  end

  def self.start(cfg)
  end

  def self.stop(cfg)
  end

  def self.restart(cfg)
  end

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
