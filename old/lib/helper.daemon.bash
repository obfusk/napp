#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/helper.daemon.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-02-28
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

# TODO {
#
#   * deal w/ old pidfile lingering after reboot !!!
#     --> init script should clean them all !?
#
# } TODO

# --

if [ "$nap_helper_daemon_loaded" == yes ]; then
  return
else
  nap_helper_daemon_loaded=yes
fi

# --

# Usage: nap_helper_daemon_nginx_port <server> <port> [<public>]
# Creates nginx config; sets $nap_helper_daemon_nginx_conf; dies on
# failure.
function nap_helper_daemon_nginx_port () {                      # {{{1
  local server="$1" port="$2" pub="$3"

  loadlib 'helper.nginx'

  nap_helper_daemon_nginx_conf="$nap_app_cfg/nginx.conf"

  if [ -n "$pub" ]; then
    cfg_nginx_public="$nap_app_app/$pub"
  else
    cfg_nginx_public=''
  fi

  cfg_nginx_server="$server"
    cfg_nginx_port="$port"
    cfg_nginx_host=localhost
     cfg_nginx_log="$nap_app_log"

  ohai '[nginx (port) mkcfg]'
  try '[nginx (port) mkcfg] failed' nap_helper_nginx_port_mkcfg \
    "$nap_helper_daemon_nginx_conf"
}                                                               # }}}1

# Usage: nap_helper_daemon_nginx_sock <server> [<public>]
# Creates nginx config; sets $nap_helper_daemon_nginx_conf; dies on
# failure.
function nap_helper_daemon_nginx_sock () {                      # {{{1
  local server="$1" pub="$2"

  loadlib 'helper.nginx'

  nap_helper_daemon_nginx_conf="$nap_app_cfg/nginx.conf"

  if [ -n "$pub" ]; then
    cfg_nginx_public="$nap_app_app/$pub"
  else
    cfg_nginx_public=''
  fi

  cfg_nginx_server="$server"
    cfg_nginx_sock="$nap_app_run/daemon.sock"
     cfg_nginx_log="$nap_app_log"

  ohai '[nginx (socket) mkcfg]'
  try '[nginx (socket) mkcfg] failed' nap_helper_nginx_sock_mkcfg \
    "$nap_helper_daemon_nginx_conf"
}                                                               # }}}1

# Usage: nap_helper_daemon_getpid
# Outputs pid from pidfile (if any).
function nap_helper_daemon_getpid () {                          # {{{1
  [ -f "$nap_app_pidfile" ] && cat "$nap_app_pidfile"
}                                                               # }}}1

# Usage: nap_helper_daemon_chk <pid> <name>
# Checks if pid is alive; warns if name not equal to command; returns
# non-zero if not alive.  NB: warning currently disabled.
function nap_helper_daemon_chk () {                             # {{{1
  local pid="$1" name="$2"
  local cmd="$( ps -p "$pid" -o comm= )"
  local c="${cmd%% *}"

  [ -z "$cmd" ] && return 1

  # if [ "$name" != "$c" ]; then
  #   opoo "process with pid $pid has command \`$c';"
  #   opoo "was expecting \`$name'"
  # fi

  return 0
}                                                               # }}}1

# Usage: nap_helper_daemon_chk_wait <n> <pid> <name>
# Waits n secs to see if process dies; dies on failure.
function nap_helper_daemon_chk_wait () {                        # {{{1
  local n="$1" pid="$2" name="$3" i

  if [ "$n" -gt 0 ]; then
    ohai "[wait $n seconds]"
    for (( i=0 ; i < n ; ++i )); do sleep 1; echo -n .; done
  fi
  if ! nap_helper_daemon_chk "$pid" "$name"; then
    [ "$n" -gt 0 ] && echo; odie 'process died'
  fi
  [ "$n" -gt 0 ] && echo ' OK'
}                                                               # }}}1

# --

# Usage: nap_helper_daemon_deps <info> <cmd> <arg(s)>
# Installs dependencies; dies on failure.
function nap_helper_daemon_deps () {                            # {{{1
  local info="$1"; shift

  ohai "$( join ' ' "$@" )"
  dpush "$nap_app_app"
    try "$info failed" "$@"
  dpop
}                                                               # }}}1

# Usage: nap_helper_daemon_status <name>
# Uses pidfile and nap_helper_daemon_chk to see if process is running;
# outputs "stopped" when stopped (no pidfile), "dead" when dead (has
# pidfile, not running), and "<pid>" when running.
function nap_helper_daemon_status () {                          # {{{1
  local name="$1"
  local pid="$( nap_helper_daemon_getpid )"

  if [ -z "$pid" ]; then
    echo stopped
  elif nap_helper_daemon_chk "$pid" "$name"; then
    echo "$pid"
  else
    echo dead
  fi
}                                                               # }}}1

function nap_helper_daemon_age () { ps -p "$1" -o etime= | tr -d ' '; }

# Usage: nap_helper_daemon_status_info <name> -[nqs]
# Human-readable version of nap_helper_daemon_status.
function nap_helper_daemon_status_info () {                     # {{{1
  local name="$1" a="$2"
  local status="$( nap_helper_daemon_status "$name" )"
  local c r=n q="$status" x=

  case "$status" in
    stopped)  c="$colour_blu" ;;
    dead)     c="$colour_red" ;;
    *)        c="$colour_grn" q=running r=y ;;
  esac

  if [[ "$r" == y && "$a" == -[ns] ]]; then
    x=" ($( nap_helper_daemon_age "$status" ) pid=$status)"
  fi

  case "$a" in
    -q) echo "$q" ;;
    -s) echo -e "${c}${q}${colour_non}${x}" ;;
    *)  ohai "[$name is ${q}${x}]" ;;
  esac
}                                                               # }}}1

# Usage: nap_helper_daemon_running <name> [warn]
# Returns 0 when running, 1 when stopped, and 2 when dead; when warn
# is passed, it warns if dead and tells if stopped.
function nap_helper_daemon_running () {                         # {{{1
  local name="$1" warn="$2"
  local status="$( nap_helper_daemon_status "$name" )"

  if [ "$status" == dead ]; then
    [ "$warn" == warn ] && opoo "$name is dead"
    return 2
  fi

  if [ "$status" == stopped ]; then
    [ "$warn" == warn ] && ohai "[$name is stopped]"
    return 1
  fi

  return 0
}                                                               # }}}1

# Usage: nap_helper_daemon_start <n> [nohup] <cmd> <arg(s)>
# Starts daemon (if not running); runs nap_helper_daemon_chk_wait;
# dies on failure.
function nap_helper_daemon_start () {                           # {{{1
  local n="$1" nohup="$2"; shift
  if [ "$nohup" == nohup ]; then shift; else nohup= ; fi

  local info="$( join ' ' "$@" )"
  local name="${info%% *}"
  local status="$( nap_helper_daemon_status "$name" )"

  if [ "$status" != stopped -a "$status" != dead ]; then
    opoo "$name is running (pid=$status)"
  else
    ohai "$info"
    dpush "$nap_app_app"
      local d="$( date +'%F %T' )"
      local info="[ $d -- nap -- starting $cfg_name ... ]"

      echo "$info" >> "$nap_app_log/daemon-stdout.log"
      echo "$info" >> "$nap_app_log/daemon-stderr.log"

      $nohup "$@"  >> "$nap_app_log/daemon-stdout.log" \
                  2>> "$nap_app_log/daemon-stderr.log" &
      local pid=$!
    dpop

    nap_helper_daemon_chk_wait "$n" "$pid" "$name"
    try '[mkpid] failed' nap_mkpid "$nap_app_pidfile" "$pid"
  fi
}                                                               # }}}1

# Usage: nap_helper_daemon_stop <info>
# Stops daemon (if running) by killing pid; dies on failure; uses
# $nap_helper_daemon_signal set by nap_helper_daemon_parse_cmd.
function nap_helper_daemon_stop () {                            # {{{1
  local info="$1"
  local name="${info%% *}" sig="$nap_helper_daemon_signal"
  local status="$( nap_helper_daemon_status "$name" )"

  if [ "$status" == stopped -o "$status" == dead ]; then
    opoo "$name is $status"
  else # running; $status is pid
    ohai "[kill ($sig)] $name"
    try '[kill] failed' kill -s "$sig" "$status"
    try '[rmpid] failed' rm "$nap_app_pidfile"
  fi
}                                                               # }}}1

# --

# Usage: nap_helper_daemon_parse_cmd <cmd>
# Parses optional SIG* prefix; (e.g. "SIGINT cmd ..."); sets
# nap_helper_daemon_{signal,cmd}.
function nap_helper_daemon_parse_cmd () {                       # {{{1
  local cmd="$1" c s

  if [[ "$cmd" =~ ^SIG[A-Z0-9]+' ' ]]; then
    s="${cmd%% *}" c="${cmd#* }"
  else
    s=SIGTERM c="$cmd"
  fi

  # if [ -n "$nap_helper_daemon_signal" ] && \
  #    [ "$nap_helper_daemon_signal" != "$s" ]; then
  #   odie 'oops! signal has changed between calls to ..._parse_cmd'
  # fi

  nap_helper_daemon_signal="$s" nap_helper_daemon_cmd="$c"
}                                                               # }}}1

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
