# --                                                            ; {{{1
#
# File        : napp/types/ruby.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-14
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
    update: nil, logdir: nil, public: nil, server: nil, ssl: false,
    default_server: false
  }

  DEFAULT_LOG = 'log'
  DEFAULT_PUB = 'public'

  TypeCfg = Util.struct *DEFAULTS.keys

  # --

  # extends Cmd::New option parser; MODIFIES cfg
  def self.options(o, cfg)                                      # {{{1
    cfg.type = TypeCfg.new DEFAULTS unless cfg.cmd.help
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
         "default DIR is #{DEFAULT_LOG}") do |x|
      cfg.type.logdir = x || DEFAULT_LOG
    end
    o.on('--public [DIR]',
         'Subdir of app with public files; optional;',
         "default DIR is #{DEFAULT_PUB}") do |x|
      cfg.type.public = x || DEFAULT_PUB
    end
    o.on('--server NAME', 'Nginx server_name; optional') do |x|
      cfg.type.server = x
    end
    o.on('--[no-]ssl', 'Nginx w/ ssl; default is no') do |x|
      cfg.type.ssl = x
    end
    o.on('--[no-]default-server',
         'Nginx w/ default_server; default is no') do |x|
      cfg.type.default_server = x
    end
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
    if t.server
      Valid.server! t.server
    else
      Util.invalid! 'invalid: ssl w/o server' if t.ssl
      Util.invalid! 'invalid: default_server w/o server' \
        if t.default_server
    end
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
