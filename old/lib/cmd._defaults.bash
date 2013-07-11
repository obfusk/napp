#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/cmd._defaults.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2012-08-24
#
# Copyright   : Copyright (C) 2012  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

# Usage: nap_cmd_run_prepare_d <n> <m> <arg(s)>
# Parses opts.
function nap_cmd_run_prepare_d () {                             # {{{1
  local usage="$nap_cmd_usage" n="$1" m="$2"; shift 2
  [ "$#" -ge "$n" ] && ( [ -z "$m" ] || [ "$#" -le "$m" ] ) \
    || die "$usage" usage
  cfg_name="$1"; shift

  validate "$cfg_name" "$chk_word" 'invalid name'

  nap_app_set
  [ -e "$nap_app" ] || die "app \`$cfg_name' does not exist"
}                                                               # }}}1

# Usage: nap_cmd_help_d
# Outputs help.
function nap_cmd_help_d () {                                    # {{{1
  sed 's!^    !!g' <<__END
    Usage: $nap_cmd_usage
__END
}                                                               # }}}1

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
