#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/cmd.new.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2012-08-07
#
# Copyright   : Copyright (C) 2012  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

nap_cmd_usage='nap new <name> <type> <repo> [<opt(s)>]'

# --

# Usage: nap_cmd_run <arg(s)>
# ...
function nap_cmd_run () {                                       # {{{1
  local usage="$nap_cmd_usage"
  [ "$#" -ge 3 ] || die "$usage" usage
  local name="$1"; cfg_type="$2" cfg_repo="$3"; shift 3
  parse_opts_handled 'vcs|branch' "$@"

  validate "$name"        '[a-z_-]+'        'invalid name'
  validate "$cfg_type"    '[a-z_-]+'        'invalid type'
  validate "$cfg_repo"    '[a-zA-Z@.:/_-]+' 'invalid repo'
  validate "$cfg_vcs"     '[a-z_-]+'        'invalid vcs'
  validate "$cfg_branch"  '[a-z_-]*'        'invalid branch'

  local app="$NAP_APPS_DIR/$name"
  [ -e "$app" ] && die "app \`$app' already exists"

  loadlib "type.$cfg_type"
  loadlib "vcs.$cfg_vcs"

  mkdir -p "$app" || die "TODO"
  nap_vcs_clone "$cfg_repo" "$app/app" $cfg_branch || die "TODO"
  nap_mkcfg "$app/cfg"
}                                                               # }}}1

# Usage: nap_cmd_help
# Outputs help.
function nap_cmd_help () {                                      # {{{1
  sed 's!^    !!g' <<__END
    Usage: $nap_cmd_usage

    Options:
      vcs=...     default is git
      branch=...  default is default branch (usually master)

    Types : $( join ', ' $( searchlibs_cat type ) )
    VCSs  : $( join ', ' $( searchlibs_cat vcs  ) )
__END
}                                                               # }}}1

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
