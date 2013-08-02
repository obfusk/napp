# --                                                            ; {{{1
#
# File        : napp/cmds/run.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-02
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Cmds; module Run

  D = ::Napp::Daemon

  USAGE = 'napp run <name> <cmd> [<arg(s)>]'

  # --

  # run command; MODIFIES cfg -> done
  def self.run(cfg, *args_)                                     # {{{1
    name_, cmd, *args = OU::Valid.args 'run', args_, 2, nil
    Cfg.load_app_config cfg, name_; name = cfg.name.join
    dir = Cfg.dir_app_app cfg
    cs  = (args.empty? && D.alias?(cfg, cmd)) \
        ? D.flatten_cmds(cfg, [cmd]).map { |x| D.sh_var_cmd x }
        : [[cmd] + args]
    OU.onow 'App', name
    cs.each do |c|
      OU.chk_exit(c) { |a| OU.ospawn_w(*a, chdir: dir) }
    end
    OU.onow 'Done.'
  end                                                           # }}}1

  # help message
  def self.help(cfg, *args_)
    OU::Valid.args 'help run', args_, 0
    "Usage: #{ USAGE }\n"
  end

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
