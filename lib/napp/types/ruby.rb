# --                                                            ; {{{1
#
# File        : napp/types/ruby.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-12
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
    listen: nil, port: nil, run: nil, bootstrap: nil, update: nil,
    logdir: nil, public: nil, server: nil
  }

  Cfg = Util.struct *DEFAULTS.keys

  # extends Cmd::New option parser
  def self.options(o, opts)                                     # {{{1
    opts.type = Cfg.new DEFAULTS unless opts.info.help
    o.on('--socket', 'Listen on socket') do |x|
      opts.type.listen = :socket
    end
    o.on('--port PORT', 'Listen on port') do |x|
      opts.type.listen = :port
      opts.type.port = x
    end
    o.on('--run CMD', 'Command to run app') do |x|
      opts.type.run = x
    end
    o.on('--bootstrap CMD',
         'Command to bootstrap app;',
         'default is update command') do |x|
      opts.type.bootstrap = x
    end
    o.on('--update CMD', 'Command to update app') do |x|
      opts.type.update = x
    end
    o.on('--logdir DIR',
         'Subdir of app with *.log files; optional') do |x|
      opts.type.logdir = x
    end
    o.on('--public DIR',
         'Subdir of app with public files; optional') do |x|
      opts.type.public = x
    end
    o.on('--server NAME', 'Nginx server_name; optional') do |x|
      opts.type.server = x
    end
  end                                                           # }}}1

  def self.validate!(opts)
  end

  # --

  def self.bootstrap(opts)
  end

  def self.status(opts)
  end

  def self.running?(opts)
  end

  def self.start(opts)
  end

  def self.stop(opts)
  end

  def self.restart(opts)
  end

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
