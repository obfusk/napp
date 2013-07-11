#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/cmd.update.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2012-08-12
#
# Copyright   : Copyright (C) 2012  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

nap_cmd_usage='nap update <name>'

loadlib 'cmd._defaults'

# --

# Usage: nap_cmd_run <arg(s)>
# Runs nap_cmd_run_prepare_d; loads libs, cfg; updates app.
function nap_cmd_run () {                                       # {{{1
  nap_cmd_run_prepare_d 1 1 "$@"

  olog 'updating ...'
  ohai "[update] \`$cfg_name'"

  source "$nap_app_cfgfile" || odie '[loadcfg] failed'
  loadlib "type.$cfg_type"
  loadlib "vcs.$cfg_vcs"

  nap_type_running warn; local run="$?"
  [ "$run" -eq 0 ] && nap_type_stop
  nap_vcs_pull "$nap_app_app" $cfg_branch
  nap_type_install_deps
  [ "$run" -eq 0 ] && nap_type_start

  ohai '[done]'
  [ "$run" -ne 0 ] && olog 'not running;'
  olog 'updated.'
  return 0
}                                                               # }}}1

# Usage: nap_cmd_help
# Outputs help.
function nap_cmd_help () { nap_cmd_help_d; }

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
