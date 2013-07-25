# --                                                            ; {{{1
#
# File        : napp/cmds/restart.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-25
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Cmds; module Restart

  USAGE = 'napp restart <name>'

  # --

  # restart app; MODIFIES cfg -> done
  def self.run(cfg, *args_)                                     # {{{1
    name_, = OU::Valid.args 'restart', args_, 1
    Cfg.load_app_config cfg, name_; name = cfg.name.join
    t = cfg.extra.type_mod; alive, ok = t.running? cfg
    cfg.logger["restarting `#{name}' ..."]
    cfg.logger["`#{name}' is not running"] if !alive
    OU.onow 'Restarting', name
    OU.opoo 'app is dead', log: cfg.logger if !alive && !ok
    OU.onow 'App is stopped' if !alive && ok
    t.restart cfg if alive && ok
    OU.onow 'Done.'
    msg = alive && ok ? 'restarted' : 'not restarted'
    cfg.logger["`#{name}' #{msg}."]
  end                                                           # }}}1

  # help message
  def self.help(cfg, *args_)
    OU::Valid.args 'help restart', args_, 0
    "Usage: #{ USAGE }\n"
  end

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
