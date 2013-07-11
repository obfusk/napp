#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/nap.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2012-10-30
#
# Copyright   : Copyright (C) 2012  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

export LC_COLLATE=C

# === cfg vars ===                                              # {{{1

   nap_commands=( new bootstrap update  \
                  start stop restart    \
                  status info log       )
                                                                # TODO
       nap_cfgs=( type repo vcs branch logdir )
       nap_opts='vcs|branch|logdir'

    nap_logfile="$NAP_LOG_DIR/nap.log"
   nap_logfiles=( "$nap_logfile" )

        nap_app=
    nap_app_app=
    nap_app_cfg=
    nap_app_log=
nap_app_cfgfile=
nap_app_pidfile=

       nap_logs=()
    nap_applogs=()

       cfg_name=
       cfg_type=
       cfg_repo=
        cfg_vcs=git
     cfg_branch=
     cfg_logdir=
                                                                # }}}1

# --

if [ -t 1 ]; then                                               # {{{1
  colour_non='\033[0m'
  colour_red='\033[1;31m'
  colour_grn='\033[1;32m'
  colour_blu='\033[1;34m'
  colour_whi='\033[1;37m'
else
  colour_non=
  colour_red=
  colour_grn=
  colour_blu=
  colour_whi=
fi                                                              # }}}1

# --

# === ckh_* ===                                                 # {{{1

chk_word='[a-z0-9_-]+'
 chk_num='[0-9]+'

chk_host='[a-z0-9.*-]+|_'
 chk_url='[a-z0-9A-Z@.:/_-]+'
                                                                # }}}1

# --

# Usage: nap_app_set
# Sets nap_app*.
function nap_app_set () {                                       # {{{1
          nap_app="$NAP_APPS_DIR/$cfg_name"
      nap_app_app="$nap_app/app"
      nap_app_cfg="$nap_app/cfg"
      nap_app_log="$nap_app/log"
      nap_app_run="$nap_app/run"
  nap_app_cfgfile="$nap_app_cfg/napprc"
  nap_app_logfile="$nap_app_log/nap.log"
  nap_app_pidfile="$nap_app_run/daemon.pid"

    nap_logfiles+=( "$nap_app_logfile" )
}                                                               # }}}1

# --

function now () { date +'%F %T'; }
function qsh () { printf '%q' "$1"; }

# Usage: olog <msg(s)>
# Writes msg(s) to log file(s).
function olog () {                                              # {{{1
  local x f h="[$( now )][nap${cfg_name:+ ($cfg_name)}]"
  for x in "$@"; do
    for f in "${nap_logfiles[@]}"; do echo "$h $x" >> "$f"; done
  done
}                                                               # }}}1

# --

# Usage: ohai <msg>
# Echoes "==> msg"; uses $colour_*.
function ohai () {                                              # {{{1
  local msg="$1"
  echo -e "${colour_blu}==>${colour_whi} ${msg}${colour_non}"
}                                                               # }}}1

# Usage: onoe <msg> [<label>]
# Echoes "Error: msg"; label replaces Error; uses $colour_*; also logs
# using olog.
function onoe () {                                              # {{{1
  local msg="$1" label="${2:-Error}"
  echo -e "${colour_red}${label}${colour_non}: ${msg}"
  olog "${label}: ${msg}"
}                                                               # }}}1

# Usage: opoo <msg>
# Runs >> onoe <msg> Warning <<.
function opoo () { onoe "$1" Warning; }

# Usage: odie <msg> [<label>]
# Exits w/ 1; uses onoe.
function odie () { onoe "$@"; exit 1; }

# --

# Usage: try <msg> <cmd> <arg(s)>
# Runs cmd w/ args; runs $try_func (or odie) w/ msg on failure.
function try () {                                               # {{{1
  local msg="$1"; shift
  "$@" || "${try_func:-odie}" "$msg"
}                                                               # }}}1

# Usage: try_q <msg> <cmd> <arg(s)>
# Like try, but redirects stderr to $try_stderr (or /dev/null).
function try_q () {                                             # {{{1
  local msg="$1"; shift
  "$@" 2>"${try_stderr:-/dev/null}" || "${try_func:-odie}" "$msg"
}                                                               # }}}1

# --

function pushd_q  () { pushd "$1" > /dev/null; }
function popd_q   () { popd       > /dev/null; }

function dpush    () { try '[pushd] failed' pushd_q "$1"; }
function dpop     () { try '[popd] failed'  popd_q      ; }

# --

# Usage: validate <str> <rx> <info>
# Matches <str> to <rx>; handles match failure w/ fail.
function validate () {                                          # {{{1
  local s="$1" rx="$2" info="$3"
  [[ "$s" =~ ^($rx)$ ]] || fail "$info"
}                                                               # }}}1

# Usage: join <sep> <arg(s)>
# Outputs args separated by <sep>; must not contain `|'.
function join () {                                              # {{{1
  local s="$1" IFS='|'; shift; local x="$*"; echo "${x//|/$s}"
}                                                               # }}}1

# --

# Usage: searchlibs_cat <cat>
# Outputs names.
function searchlibs_cat () {                                    # {{{1
  local cat="$1"
  searchlibs "$cat"'\..*' | sed -E 's!^.*/'"$cat"'\.(.*)\.bash$!\1!'
}                                                               # }}}1

# Usage: nap_cmds <sep>
# Outputs nap commands separated by <sep>.
function nap_cmds () { join "$1" "${nap_commands[@]}"; }

# Usage: nap_help
# Outputs help; exits w/ 0.
function nap_help () {                                          # {{{1
  sed 's!^    !!g' <<__END
    nap version $vsn

    Usage     : $usage
    Commands  : $( nap_cmds ', ' )
__END
  exit 0
}                                                               # }}}1

# Usage: nap_mkcfg <file>
# Writes cfg_* to file; returns non-zero on failure.
function nap_mkcfg () {                                         # {{{1
  local f="$1"
  sed 's!^    !!g' <<__END > "$f"
    # basic configuration

    $(  for x in "${nap_cfgs[@]}"; do
          eval "y=\$cfg_$x"
          echo "cfg_$x=$( qsh "$y" )"
        done  )

    # type-specific configuration

    $(  for x in "${nap_type_opts[@]}"; do
          eval "y=\$cfg_${cfg_type}_$x"
          echo "cfg_${cfg_type}_$x=$( qsh "$y" )"
        done  )

    # --
__END
}                                                               # }}}1

# Usage: nap_showcfg [-q]
# Shows cfg_*.
function nap_showcfg () {                                       # {{{1
  local q="$1" pre=
  [ "$q" == -q ] || pre='  '

  [ "$q" == -q ] || ohai "Basic Configuration"
  for x in "${nap_cfgs[@]}"; do
    eval "y=\$cfg_$x"
    printf "%-19s : %s\n" "$pre$x" "$y"
  done

  [ "$q" == -q ] || ohai "Type-Specific Configuration"
  for x in "${nap_type_opts[@]}"; do
    eval "y=\$cfg_${cfg_type}_$x"
    printf "%-19s : %s\n" "$pre$cfg_type.$x" "$y"
  done
}                                                               # }}}1

# Usage: nap_mkpid <file> <pid>
# Writes pid to file; returns non-zero on failure.
function nap_mkpid () { local f="$1" pid="$2"; echo "$pid" > "$f"; }

# --

# Usage: nap_find_logs
# Sets $nap_{app,}logs to .../log/*.log.
function nap_find_logs () {                                     # {{{1
  shopt -s nullglob
  nap_logs=( "$nap_app_log"/*.log )
  [ -n "$cfg_logdir" ] \
    && nap_applogs=( "$nap_app_app/$cfg_logdir"/*.log )
  shopt -u nullglob
}                                                               # }}}1

# Usage: nap_log_list
# Outputs log names; /path/to/foo.log becomes foo; app log becomes
# @foo.
function nap_log_list () {                                      # {{{1
  local x
  for x in "${nap_logs[@]}"; do
    echo "$( basename "$x" .log )"
  done
  for x in "${nap_applogs[@]}"; do
    echo "@$( basename "$x" .log )"
  done
}                                                               # }}}1

# Usage: nap_log_files
# Outputs log paths.
function nap_log_files () {                                     # {{{1
  local x
  for x in "${nap_logs[@]}" "${nap_applogs[@]}"; do echo "$x"; done
}                                                               # }}}1

# Usage: nap_log_assoc
# Outputs log names and files.
function nap_log_assoc () {                                     # {{{1
  local x
  for x in "${nap_logs[@]}"; do
    printf '%-19s %s\n' "$( basename "$x" .log )" "$x"
  done
  for x in "${nap_applogs[@]}"; do
    printf '%-19s %s\n' "@$( basename "$x" .log )" "$x"
  done
}                                                               # }}}1

# Usage: nap_log_tail <n> [<log(s)>]
# Uses tail to show specified log(s); no logs means all logs.
function nap_log_tail () {                                      # {{{1
  local n="$1" logs=() x; shift

  if [ "$#" -eq 0 ]; then
    logs=( "${nap_logs[@]}" "${nap_applogs[@]}" )
  else
    for x in "$@"; do
      if [[ "$x" == @* ]]; then
        [ -z "$cfg_logdir" ] && odie 'logdir not set'
        logs+=( "$nap_app_app/$cfg_logdir/${x:1}".log )
      else
        logs+=( "$nap_app_log/$x".log )
      fi
    done
  fi

  for x in "${logs[@]}"; do
    ohai "$x"
    try 'tail failed' tail -n "$n" -- "$x"
  done
}                                                               # }}}1

# Usage: nap_log_monitor <n> <log>
# Monitors /path/to/<log>.log using tail -f.
function nap_log_monitor () {                                   # {{{1
  local n="$1" l="$2" f

  if [[ "$l" == @* ]]; then
    [ -z "$cfg_logdir" ] && odie 'logdir not set'
    f="$nap_app_app/$cfg_logdir/${l:1}".log
  else
    f="$nap_app_log/$l".log
  fi

  ohai "$f"
  tail -n "$n" -f -- "$f"
}                                                               # }}}1

# --

# Usage   : parse_opts <opt-rx> <arg(s)>
# Example : parse_opts 'foo|bar' foo=99 bar=100
#
# Sets cfg_<opt> for each opt parsed; returns 0 on success.
# Returns 1 and sets $parse_opts_error to arg on non-parseable arg.
# Returns 2 and sets $parse_opts_error to opt on not-recognized opt.
#
# TODO: array opts: cfg_$k+=( \$v ) ???

function parse_opts () {                                        # {{{1
  local ok="$1" x k v; shift
  for x in "$@"; do
    [[ "$x" =~ ^([a-z.]+)=(.*)$ ]] \
      || { parse_opts_error="$x"; return 1; }
    k="${BASH_REMATCH[1]}" v="${BASH_REMATCH[2]}"
    [[ "$k" =~ ^($ok)$ ]] \
      || { parse_opts_error="$k"; return 2; }
    eval "cfg_${k//./_}=\$v"
  done
}                                                               # }}}1

# Usage: parse_opts_handled <opt-rx> <arg(s)>
# Runs parse_opts; handles errors w/ fail.
function parse_opts_handled () {                                # {{{1
  local ok="$1" e; shift
  parse_opts "$ok" "$@"; e="$?"
  [ "$e" -eq 1 ] && fail "malformed option: \`$parse_opts_error'"
  [ "$e" -eq 2 ] && fail "unknown option: \`$parse_opts_error'"
}                                                               # }}}1

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
