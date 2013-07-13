# --                                                            ; {{{1
#
# File        : napp/types/ruby.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-13
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
    update: nil, logdir: nil, public: nil, server: nil
  }

  TypeCfg = Util.struct *DEFAULTS.keys

  # extends Cmd::New option parser
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
         'default with no argument is log') do |x|
      cfg.type.logdir = x || 'log'
    end
    o.on('--public [DIR]',
         'Subdir of app with public files; optional;',
         'default with no argument is public') do |x|
      cfg.type.public = x || 'public'
    end
    o.on('--server NAME', 'Nginx server_name; optional') do |x|
      cfg.type.server = x
    end
  end                                                           # }}}1

  def self.validate!(cfg)
  end

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
