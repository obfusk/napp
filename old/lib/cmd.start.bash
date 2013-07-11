#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/cmd.start.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2012-08-12
#
# Copyright   : Copyright (C) 2012  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

nap_cmd_usage='nap start <name>'

loadlib 'cmd._defaults'

# --

# Usage: nap_cmd_run <arg(s)>
# Runs nap_cmd_run_prepare_d; loads libs, cfg; starts app.
function nap_cmd_run () {                                       # {{{1
  nap_cmd_run_prepare_d 1 1 "$@"

  olog 'starting ...'
  ohai "[start] \`$cfg_name'"

  source "$nap_app_cfgfile" || odie '[loadcfg] failed'
  loadlib "type.$cfg_type"

  nap_type_start

  ohai '[done]'
  olog 'started.'
  return 0
}                                                               # }}}1

# Usage: nap_cmd_help
# Outputs help.
function nap_cmd_help () { nap_cmd_help_d; }

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
