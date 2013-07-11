#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/cmd.log.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2012-08-31
#
# Copyright   : Copyright (C) 2012  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

nap_cmd_subs=( list files assoc tail monitor hist )
nap_cmd_subs_j="$( join ' | ' "${nap_cmd_subs[@]}" )"

nap_cmd_usage_p='nap log <name>'
nap_cmd_usage="$nap_cmd_usage_p { $nap_cmd_subs_j } ..."

nap_cmd_usage__list="$nap_cmd_usage_p list"                     # {{{1
nap_cmd_usage__fils="$nap_cmd_usage_p files"
nap_cmd_usage__assc="$nap_cmd_usage_p assoc"
nap_cmd_usage__tail="$nap_cmd_usage_p tail <n> [<log(s)>]"
nap_cmd_usage__moni="$nap_cmd_usage_p monitor <n> <log>"
nap_cmd_usage__hist="$nap_cmd_usage_p hist <n> [-v]"            # }}}1

loadlib 'cmd._defaults'

# --

# Usage: nap_cmd_run_sub <cmd> <arg(s)>
# Validates args, runs subcommand.
function nap_cmd_run_sub () {                                   # {{{1
  local usage="$nap_cmd_usage" cmd="$1"; shift

  case "$cmd" in
    list)
      [ "$#" -eq 0 ] || die "$nap_cmd_usage__list" usage
      nap_log_list
    ;;
    files)
      [ "$#" -eq 0 ] || die "$nap_cmd_usage__fils" usage
      nap_log_files
    ;;
    assoc)
      [ "$#" -eq 0 ] || die "$nap_cmd_usage__assc" usage
      nap_log_assoc
    ;;
    tail)
      [ "$#" -ge 1 ] || die "$nap_cmd_usage__tail" usage
      local n="$1"; shift
      validate "$n" "$chk_num" 'invalid n'
      nap_log_tail "$n" "$@"
    ;;
    monitor)
      [ "$#" -eq 2 ] || die "$nap_cmd_usage__moni" usage
      local n="$1" log="$2"
      validate "$n" "$chk_num" 'invalid n'
      nap_log_monitor "$n" "$log"
    ;;
    hist)
      [ "$#" -ge 1 -a "$#" -le 2 ] || die "$nap_cmd_usage__hist" usage
      local n="$1" v="$2"
      validate "$n" "$chk_num" 'invalid n'
      [ -z "$v" -o "$v" == -v ] || die "$nap_cmd_usage__hist" usage
      nap_vcs_log "$nap_app_app" "$n" $v
    ;;
  esac
}                                                               # }}}1

# Usage: nap_cmd_run <arg(s)>
# Runs nap_cmd_run_prepare_d; loads libs, cfg; runs nap_cmd_run_sub.
function nap_cmd_run () {                                       # {{{1
  nap_cmd_run_prepare_d 2 '' "$@"

  local cmd="$2"; shift 2
  [[ "$cmd" =~ ^($( join '|' "${nap_cmd_subs[@]}" ))$ ]] \
    || die "$nap_cmd_usage" usage

  source "$nap_app_cfgfile" || odie '[loadcfg] failed'
  loadlib "type.$cfg_type"
  loadlib "vcs.$cfg_vcs"

  nap_find_logs
  nap_cmd_run_sub "$cmd" "$@"
  return 0
}                                                               # }}}1

# Usage: nap_cmd_help
# Outputs help.
function nap_cmd_help () {                                      # {{{1
  sed 's!^    !!g' <<__END
    Usage: $nap_cmd_usage__list
           $nap_cmd_usage__fils
           $nap_cmd_usage__assc
           $nap_cmd_usage__tail
           $nap_cmd_usage__moni
           $nap_cmd_usage__hist
__END
}                                                               # }}}1

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
