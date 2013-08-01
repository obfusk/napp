# --                                                            ; {{{1
#
# File        : napp/types/daemon.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-01
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/daemon'
require 'napp/nginx'

module Napp; module Types; module Daemon

  D = ::Napp::Daemon

  DEFAULTS = {
    type: 'daemon', listen: nil, port: false, run: nil, bootstrap: [],
    update: [], logdir: false, public: false, wait_start: nil,
    wait_stop: nil, nginx: false
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
    d   = cfg.global.defaults['types']['daemon']
    dd  = cfg.global.defaults['daemon']
    o.on('-s', '--socket', 'Listen on socket') do |x|
      type.listen = :socket
    end
    o.on('-p', '--port PORT', Integer, 'Listen on port') do |x|
      type.listen = :port; type.port = x
    end
    o.on('-r', '--run CMD', 'Command to run app') do |x|
      type.run = x
    end
    o.on('-B', '--bootstrap CMD',
         'Command(s) to bootstrap app;',
         'default is update command') do |x|
      type.bootstrap << x
    end
    o.on('-u', '--update CMD', 'Command(s) to update app') do |x|
      type.update << x
    end
    o.on('-l', '--logdir [DIR]',
         'Subdir of app with *.log files; optional;',
         "default DIR is #{d['logdir']}") do |x|
      type.logdir = x || d['logdir']
    end
    o.on('-P', '--public [DIR]',
         'Subdir of app with public files; optional;',
         "default DIR is #{d['public']}") do |x|
      type.public = x || d['public']
    end
    o.on('-w', '--wait-start SECONDS', Integer,
         'Wait a few seconds for the app to start;',
         "default is #{dd['wait_start']}") do |x|
      type.wait_start = x
    end
    o.on('-W', '--wait-stop SECONDS', Integer,
         'Wait a few seconds for the app to stop;',
         "default is #{dd['wait_stop']}") do |x|
      type.wait_stop = x
    end
    type.nginx = Nginx::NginxCfg.new if type  # temporary
    Nginx.options o, cfg, (type && type.nginx)
  end                                                           # }}}1

  # validate type cfg; set defaults; MODIFIES cfg
  def self.prepare!(cfg, type)                                  # {{{1
    # NB: nothing to validate for commands except presence
    type.bootstrap = type.update.dup if type.bootstrap.empty?
    type.wait_start ||= cfg.global.defaults['daemon']['wait_start']
    type.wait_stop  ||= cfg.global.defaults['daemon']['wait_stop']
    OU::Valid.invalid! 'no socket or port' unless type.listen
    OU::Valid.invalid! 'no run command' unless type.run
    OU::Valid.invalid! 'no update command(s)' if type.update.empty?
    Valid.port! type.port if type.listen == :port
    Valid.path! 'logdir', type.logdir if type.logdir
    Valid.path! 'public', type.public if type.public
    Valid.seconds! type.wait_start
    Valid.seconds! type.wait_stop
    type.nginx = Nginx.prepare!(cfg, type.nginx)
    type.nginx.freeze if type.nginx   # done.
    # TODO: build/check! nginx ?!
    if type.listen == :port && Valid.priviliged_port?(type.port)
      OU.opoo "port #{type.port} is priviliged"
    end
    type.bootstrap.freeze; type.update.freeze
  end                                                           # }}}1

  # --

  # bootstrap app
  def self.bootstrap(cfg)
    D.bootstrap cfg
  end

  # update app
  def self.update(cfg)
    D.update cfg
  end

  # --

  # is app running?
  def self.running?(cfg)
    D.running? cfg
  end

  # show app status; how: :quiet|short|verbose
  def self.status(cfg, how)
    D.status cfg, how
  end

  # --

  # start app
  def self.start(cfg)
    sock = cfg.type.listen == :socket ? Cfg.file_app_sock(cfg) : nil
    port = cfg.type.listen == :port ? cfg.type.port.to_s : nil
    vars = { 'SOCKET' => sock, 'PORT' => port }
    Util.rm_if_exists sock if sock
    D.start cfg, vars: vars, env: vars, n: cfg.type.wait_start
  end

  # stop app
  def self.stop(cfg)
    D.stop cfg, n: cfg.type.wait_stop
  end

  # restart app
  def self.restart(cfg)
    stop cfg; start cfg
  end

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
