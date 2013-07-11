#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/cmd.new.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2012-10-30
#
# Copyright   : Copyright (C) 2012  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

nap_cmd_usage='nap new <name> <type> <repo> [<opt(s)>]'

# --

# Usage: nap_cmd_run_prepare <arg(s)>
# Parses opts; loads libs.
function nap_cmd_run_prepare () {                               # {{{1
  local usage="$nap_cmd_usage"
  [ "$#" -ge 3 ] || die "$usage" usage
  cfg_name="$1" cfg_type="$2" cfg_repo="$3"; shift 3

  validate "$cfg_name" "$chk_word" 'invalid name'
  validate "$cfg_type" "$chk_word" 'invalid type'
  validate "$cfg_repo" "$chk_url"  'invalid repo'

  loadlib "type.$cfg_type"

  local opts="$nap_opts"
  if [ "${#nap_type_opts[@]}" -gt 0 ]; then
    opts+="|$cfg_type\.($( join '|' "${nap_type_opts[@]}" ))"
  fi

  parse_opts_handled "$opts" "$@"

  validate "$cfg_vcs"     "$chk_word"     'invalid vcs'
  validate "$cfg_branch"  "()|$chk_word"  'invalid branch'
  # no validation for logdir (!?)

  nap_type_validate_opts

  olog "creating app \`$cfg_name' ..."

  nap_app_set
  [ -e "$nap_app" ] && die "app \`$cfg_name' already exists"

  loadlib "vcs.$cfg_vcs"
}                                                               # }}}1

# Usage: nap_cmd_run <arg(s)>
# Runs nap_cmd_run_prepare; makes app w/ clone, cfg.
function nap_cmd_run () {                                       # {{{1
  nap_cmd_run_prepare "$@"

  ohai "[new app] \`$cfg_name'"

  try '[mkdir] failed'      mkdir "$nap_app"
  try '[mkdir cfg] failed'  mkdir "$nap_app_cfg"
  try '[mkdir log] failed'  mkdir "$nap_app_log"
  try '[mkdir run] failed'  mkdir "$nap_app_run"

  nap_vcs_clone "$cfg_repo" "$nap_app_app" $cfg_branch

  ohai '[mkcfg]'
  try '[mkcfg] failed' nap_mkcfg "$nap_app_cfgfile"

  ohai '[done]'

  olog "app \`$cfg_name' created."
  return 0
}                                                               # }}}1

# Usage: nap_cmd_help
# Outputs help.
function nap_cmd_help () {                                      # {{{1
  sed 's!^    !!g' <<__END
    Usage: $nap_cmd_usage

    Options:
      vcs=...                 default is git
      branch=...              default is master
      <type>.<option>=...

    Types : $( join ', ' $( searchlibs_cat type ) )
    VCSs  : $( join ', ' $( searchlibs_cat vcs  ) )
__END
}                                                               # }}}1

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
