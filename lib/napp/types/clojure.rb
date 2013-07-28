# --                                                            ; {{{1
#
# File        : napp/types/clojure.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-28
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/daemon'
require 'napp/nginx'

module Napp; module Types; module Clojure

  DEFAULTS = {
    type: 'clojure', listen: nil, port: false, run: nil,
    bootstrap: nil, update: nil, logdir: false, public: false,
    nginx: false
  }

  TypeCfg = OU.struct(*DEFAULTS.keys) do                        # {{{1
    # load callback
    def load
      # fields can be nil
      self.nginx = Nginx::NginxCfg.new self.nginx if self.nginx
    end
    # dump callback; returns hash
    def dump
      x = self.to_str_h
      x['nginx'] = x['nginx'].to_str_h if x['nginx']
      x
    end
  end                                                           # }}}1

  # --

  # extends Cmd::New option parser; MODIFIES cfg
  def self.options(o, cfg, type)                                # {{{1
    d = cfg.global.defaults['clojure']
    o.on('--port PORT', Integer, 'Listen on port') do |x|
      type.listen = :port; type.port = x
    end
    o.on('--run CMD', 'Command to run app') do |x|
      type.run = x
    end
    o.on('--bootstrap CMD',
         'Command to bootstrap app;',
         'default is update command') do |x|
      type.bootstrap = x
    end
    o.on('--update CMD', 'Command to update app') do |x|
      type.update = x
    end
    o.on('--logdir [DIR]',
         'Subdir of app with *.log files; optional;',
         "default DIR is #{d['logdir']}") do |x|
      type.logdir = x || d['logdir']
    end
    o.on('--public [DIR]',
         'Subdir of app with public files; optional;',
         "default DIR is #{d['public']}") do |x|
      type.public = x || d['public']
    end
    type.nginx = Nginx::NginxCfg.new if type  # temporary
    Nginx.options o, cfg, (type && type.nginx)
  end                                                           # }}}1

  # validate type cfg; set defaults; MODIFIES cfg
  def self.prepare!(cfg, type)                                  # {{{1
    # NB: nothing to validate for commands except presence
    type.bootstrap = type.update unless type.bootstrap
    OU::Valid.invalid! 'no port' unless type.listen             # !!!!
    OU::Valid.invalid! 'no run command' unless type.run
    OU::Valid.invalid! 'no update command' unless type.update
    Valid.port! type.port                                       # !!!!
    Valid.path! 'logdir', type.logdir if type.logdir
    Valid.path! 'public', type.public if type.public
    type.nginx = Nginx.prepare!(cfg, type.nginx)
    type.nginx.freeze if type.nginx   # done.
    # TODO: build/check! nginx ?!
    if Valid.priviliged_port?(type.port)                        # !!!!
      OU.opoo "port #{type.port} is priviliged"
    end
  end                                                           # }}}1

  # --

  # bootstrap app
  def self.bootstrap(cfg)
    Daemon.bootstrap cfg
  end

  # update app
  def self.update(cfg)
    Daemon.update cfg
  end

  # --

  # is app running?
  def self.running?(cfg)
    Daemon.running? cfg
  end

  # show app status; how: :quiet|short|verbose
  def self.status(cfg, how)
    Daemon.status cfg, how
  end

  # --

  # start app
  def self.start(cfg)
    port  = cfg.type.port.to_s                                  # !!!!
    vars  = { 'PORT' => port }
    n     = cfg.global.defaults['daemon']['wait']
    Daemon.start cfg, vars: vars, env: vars, n: n
  end

  # stop app
  def self.stop(cfg)
    Daemon.stop cfg
  end

  # restart app
  def self.restart(cfg)
    stop cfg; start cfg
  end

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
