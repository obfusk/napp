# --                                                            ; {{{1
#
# File        : napp/cmds/update.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-22
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Cmds; module Update

  USAGE = 'napp update <name>'

  # --

  # update app; MODIFIES cfg -> done
  def self.run(cfg, *args_)                                     # {{{1
    name_, = OU::Valid.args 'update', args_, 1
    Cfg.load_app_config cfg, name_; name = cfg.name.join
    t = cfg.extra.type_mod; alive, ok = t.running?
    cfg.logger["updating `#{name}' ..."]
    cfg.logger["`#{name}' is not running"] if !alive
    OU.onow 'Updating', name
    OU.opoo 'app is dead', log: cfg.logger if !alive && !ok
    OU.ohai 'App is stopped' if !alive && ok
    t.stop cfg if alive && ok
    cfg.extra.vcs_mod.pull Cfg.dir_app_app(cfg), cfg.app.branch
    t.update cfg
    t.start cfg if alive && ok
    OU.onow 'Done.'
    cfg.logger["`#{name}' updated."]
  end                                                           # }}}1

  # help message
  def self.help(cfg, *args_)
    OU::Valid.args 'help update', args_, 0
    "Usage: #{ USAGE }\n"
  end

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
