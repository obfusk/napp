# --                                                            ; {{{1
#
# File        : napp/cmds/start.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-25
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Cmds; module Start

  USAGE = 'napp start <name>'

  # --

  # start app; MODIFIES cfg -> done
  def self.run(cfg, *args_)                                     # {{{1
    name_, = OU::Valid.args 'start', args_, 1
    Cfg.load_app_config cfg, name_; name = cfg.name.join
    cfg.logger["starting `#{name}' ..."]
    OU.onow 'Starting', name
    cfg.extra.type_mod.start cfg
    OU.onow 'Done.'
    cfg.logger["`#{name}' started."]
  end                                                           # }}}1

  # help message
  def self.help(cfg, *args_)
    OU::Valid.args 'help start', args_, 0
    "Usage: #{ USAGE }\n"
  end

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
