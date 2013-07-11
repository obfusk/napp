#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/type.clj.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2012-11-29
#
# Copyright   : Copyright (C) 2012  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

# --

   nap_type_opts=( nginx server port cmd depcmd )
   cfg_clj_cmd_d="${NAP_D_CLJ_CMD:-lein trampoline run :prod}"
cfg_clj_depcmd_d="${NAP_D_CLJ_DEPCMD:-lein deps}"

loadlib 'helper.daemon'

# --

if [ -n "$cfg_clj_cmd" ]; then
  # should only be skipped for cmd.new, which is OK
  nap_helper_daemon_parse_cmd "$cfg_clj_cmd"
  cfg_clj_cmd_="$nap_helper_daemon_cmd"
fi

# --

# Usage: nap_type_validate_opts
# Validates cfg_clj_*; sets default cfg_clj_{,dep}cmd.
function nap_type_validate_opts () {                            # {{{1
  validate "$cfg_clj_nginx" '()|port'   'invalid clj.nginx'
  validate "$cfg_clj_port"  "$chk_num"  'invalid clj.port'

  if [ -n "$cfg_clj_nginx" ]; then
    validate "$cfg_clj_server" "$chk_host" 'invalid clj.server'
  else
    [ -z "$cfg_clj_server" ] \
      || fail 'invalid: clj.server w/o clj.nginx'
  fi

  # don't validate $cfg_clj_{,dep}cmd -- is command line
  : ${cfg_clj_cmd:="$cfg_clj_cmd_d"}
  : ${cfg_clj_depcmd:="$cfg_clj_depcmd_d"}
}                                                               # }}}1

# Usage: nap_type_install_deps
# Installs dependencies; dies on failure.
function nap_type_install_deps () {                             # {{{1
  nap_helper_daemon_deps "$cfg_clj_depcmd" $cfg_clj_depcmd
}                                                               # }}}1

# Usage: nap_type_bootstrap
# Bootstraps; dies on failure.
function nap_type_bootstrap () {                                # {{{1
  if [ "$cfg_clj_nginx" == port ]; then
    nap_helper_daemon_nginx_port "$cfg_clj_server" "$cfg_clj_port"
  fi
}                                                               # }}}1

# Usage: nap_type_bootstrap_info
# Outputs info.
function nap_type_bootstrap_info () {                           # {{{1
  if [ "$cfg_clj_nginx" == port ]; then
    ohai 'Caveats'
    nap_helper_nginx_info "clojure ($cfg_clj_cmd_)" \
      "$nap_helper_daemon_nginx_conf"
  fi
}                                                               # }}}1

# --

# Usage: nap_type_status -[nqs]
# Outputs daemon status.
function nap_type_status () {                                   # {{{1
  nap_helper_daemon_status_info "${cfg_clj_cmd_%% *}" "$1"
}                                                               # }}}1

# Usage: nap_type_running [warn]
# Returns non-zero if not running; warns if dead when warn is passed.
function nap_type_running () {                                  # {{{1
  nap_helper_daemon_running "${cfg_clj_cmd_%% *}" ${1:+"$1"}
}                                                               # }}}1

# Usage: nap_type_start
# Starts daemon; dies on failure.
function nap_type_start () {                                    # {{{1
  ohai "PORT=$cfg_clj_port"
  # don't quote cmd -- is command line
  PORT="$cfg_clj_port" nap_helper_daemon_start 7 nohup $cfg_clj_cmd_
}                                                               # }}}1

# Usage: nap_type_stop
# Stops daemon; dies on failure.
function nap_type_stop () {                                     # {{{1
  nap_helper_daemon_stop "$cfg_clj_cmd_"
}                                                               # }}}1

# Usage: nap_type_restart
# Restarts daemon; dies on failure.
function nap_type_restart () {                                  # {{{1
  nap_type_stop
  nap_type_start
}                                                               # }}}1

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
