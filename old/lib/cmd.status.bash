#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/cmd.status.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2012-08-25
#
# Copyright   : Copyright (C) 2012  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

nap_cmd_usage='nap status <name> [ -q | -s ]'

loadlib 'cmd._defaults'

# --

# Usage: nap_cmd_run <arg(s)>
# Runs nap_cmd_run_prepare_d; loads libs, cfg; shows app status.
function nap_cmd_run () {                                       # {{{1
  nap_cmd_run_prepare_d 1 2 "$@"

  local a="$2"
  [[ -z "$a" || "$a" == -[qs] ]] || die "$nap_cmd_usage" usage

  [ -z "$a" ] && ohai "[status] \`$cfg_name'"

  source "$nap_app_cfgfile" || odie '[loadcfg] failed'
  loadlib "type.$cfg_type"

  nap_type_status "${a:--n}"
  return 0
}                                                               # }}}1

# Usage: nap_cmd_help
# Outputs help.
function nap_cmd_help () { nap_cmd_help_d; }

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
