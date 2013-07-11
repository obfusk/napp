#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/type.ruby.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-04-29
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

# --

    nap_type_opts=( nginx server port cmd depcmd public )
   cfg_ruby_cmd_d="${NAP_D_RUBY_CMD:-"SIGINT bundle exec rackup -E production \${LISTEN}"}"
cfg_ruby_depcmd_d="${NAP_D_RUBY_DEPCMD:-bundle install}"

loadlib 'helper.daemon'

# --

if [ -n "$cfg_ruby_cmd" ]; then
  # should only be skipped for cmd.new, which is OK
  nap_helper_daemon_parse_cmd "$cfg_ruby_cmd"
  cfg_ruby_cmd_="$nap_helper_daemon_cmd"
fi

# --

# Usage: nap_type_validate_opts
# Validates cfg_ruby_*; sets default cfg_ruby_{,dep}cmd.
function nap_type_validate_opts () {                            # {{{1
  validate "$cfg_ruby_nginx" '()|port|sock' 'invalid ruby.nginx'

  if [ -n "$cfg_ruby_nginx" ]; then
    validate "$cfg_ruby_server" "$chk_host" 'invalid ruby.server'
  else
    [ -z "$cfg_ruby_server" ] \
      || fail 'invalid: ruby.server w/o ruby.nginx'
  fi

  if [ "$cfg_ruby_nginx" == sock ]; then
    [ -z "$cfg_ruby_port" ] \
      || fail 'invalid: ruby.port w/ ruby.nginx == sock'
  else
    validate "$cfg_ruby_port" "$chk_num" 'invalid ruby.port'
  fi

  # no validation for public (!?)
  [ -n "$cfg_ruby_public" -a -z "$cfg_ruby_nginx" ] \
    && fail 'invalid: ruby.public w/o ruby.nginx'

  # don't validate $cfg_ruby_{,dep}cmd -- is command line
  : ${cfg_ruby_cmd:="$cfg_ruby_cmd_d"}
  : ${cfg_ruby_depcmd:="$cfg_ruby_depcmd_d"}
}                                                               # }}}1

# Usage: nap_type_install_deps
# Installs dependencies; dies on failure.
function nap_type_install_deps () {                             # {{{1
  nap_helper_daemon_deps "$cfg_ruby_depcmd" $cfg_ruby_depcmd
}                                                               # }}}1

# Usage: nap_type_bootstrap
# Bootstraps; dies on failure.
function nap_type_bootstrap () {                                # {{{1
  case "$cfg_ruby_nginx" in
    port)
      nap_helper_daemon_nginx_port \
        "$cfg_ruby_server" "$cfg_ruby_port" "$cfg_ruby_public"
    ;;
    sock)
      nap_helper_daemon_nginx_sock \
        "$cfg_ruby_server" "$cfg_ruby_public"
    ;;
  esac
}                                                               # }}}1

# Usage: nap_type_bootstrap_info
# Outputs info.
function nap_type_bootstrap_info () {                           # {{{1
  if [[ "$cfg_ruby_nginx" =~ ^(port|sock)$ ]]; then
    ohai 'Caveats'
    nap_helper_nginx_info "ruby ($cfg_ruby_cmd_)" \
      "$nap_helper_daemon_nginx_conf"
  fi
}                                                               # }}}1

# --

# Usage: nap_type_status -[nqs]
# Outputs daemon status.
function nap_type_status () {                                   # {{{1
  nap_helper_daemon_status_info "${cfg_ruby_cmd_%% *}" "$1"
}                                                               # }}}1

# Usage: nap_type_running [warn]
# Returns non-zero if not running; warns if dead when warn is passed.
function nap_type_running () {                                  # {{{1
  nap_helper_daemon_running "${cfg_ruby_cmd_%% *}" ${1:+"$1"}
}                                                               # }}}1

# Usage: nap_type_start
# Starts daemon; dies on failure.
function nap_type_start () {                                    # {{{1
  local cmd= sock= port=

  if [ "$cfg_ruby_nginx" == sock ]; then
    sock="$nap_app_run/daemon.sock"
    cmd_="${cfg_ruby_cmd_//\${LISTEN\}/-l $sock}"
    cmd="${cmd_//\${SOCKET\}/$sock}"
    ohai "SOCKET=$sock"
  else
    port="$cfg_ruby_port"
    cmd_="${cfg_ruby_cmd_//\${LISTEN\}/-p $port}"
    cmd="${cmd_//\${PORT\}/$port}"
    ohai "PORT=$port"
  fi

  # remove socket -- e.g. puma has issues w/ old sockets
  [ -n "$sock" ] && rm -f "$sock"

  # don't quote cmd -- is command line
  PORT="$port" SOCKET="$sock" nap_helper_daemon_start 7 nohup $cmd
}                                                               # }}}1

# Usage: nap_type_stop
# Stops daemon; dies on failure.
function nap_type_stop () {                                     # {{{1
  nap_helper_daemon_stop "$cfg_ruby_cmd_"
}                                                               # }}}1

# Usage: nap_type_restart
# Restarts daemon; dies on failure.
function nap_type_restart () {                                  # {{{1
  nap_type_stop
  nap_type_start
}                                                               # }}}1

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
