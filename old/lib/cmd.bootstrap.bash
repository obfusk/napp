#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/cmd.bootstrap.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2012-08-12
#
# Copyright   : Copyright (C) 2012  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

nap_cmd_usage='nap bootstrap <name>'

loadlib 'cmd._defaults'

# --

# Usage: nap_cmd_run <arg(s)>
# Runs nap_cmd_run_prepare_d; loads libs, cfg; bootstraps app.
function nap_cmd_run () {                                       # {{{1
  nap_cmd_run_prepare_d 1 1 "$@"

  olog 'bootstrapping ...'
  ohai "[bootstap] \`$cfg_name'"

  source "$nap_app_cfgfile" || odie '[loadcfg] failed'
  loadlib "type.$cfg_type"

  nap_type_bootstrap
  nap_type_install_deps
  ohai '[done]'
  nap_type_bootstrap_info

  olog 'bootstrapped.'
  return 0
}                                                               # }}}1

# Usage: nap_cmd_help
# Outputs help.
function nap_cmd_help () { nap_cmd_help_d; }

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
