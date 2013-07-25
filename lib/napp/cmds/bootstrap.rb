# --                                                            ; {{{1
#
# File        : napp/cmds/bootstrap.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-25
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Cmds; module Bootstrap

  USAGE = 'napp bootstrap <name>'

  # --

  # bootstrap app; MODIFIES cfg -> done
  def self.run(cfg, *args_)                                     # {{{1
    name_, = OU::Valid.args 'bootstrap', args_, 1
    Cfg.load_app_config cfg, name_; name = cfg.name.join
    cfg.logger["bootstrapping `#{name}' ..."]
    OU.onow 'Bootstrapping', name
    cfg.extra.type_mod.bootstrap cfg
    OU.onow 'Done.'
    cfg.logger["`#{name}' bootstrapped."]
  end                                                           # }}}1

  # help message
  def self.help(cfg, *args_)
    OU::Valid.args 'help bootstrap', args_, 0
    "Usage: #{ USAGE }\n"
  end

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
