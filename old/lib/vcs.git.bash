#!/bin/bash

# --                                                            # {{{1
#
# File        : lib/vcs.git.bash
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-02-28
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            # }}}1

# Usage: nap_vcs_clone <repo> <dir> [<branch>]
# Clones repo's branch (or master) to dir; dies on failure.
function nap_vcs_clone () {                                     # {{{1
  local repo="$1" dir="$2" b="$3"
  local cmd=( git clone -b "${b:-master}" "$repo" "$dir" )

  ohai "$( join ' ' "${cmd[@]}" )"
  try 'git clone failed' "${cmd[@]}"
}                                                               # }}}1

# Usage: nap_vcs_pull <dir> [<branch>]
# Pulls origin's branch (or master); dies on failure.
function nap_vcs_pull () {                                      # {{{1
  local dir="$1" b="$2"
  local cmd=( git pull origin "${b:-master}" )

  dpush "$dir"
    ohai "$( join ' ' "${cmd[@]}" )"
    try 'git pull failed' "${cmd[@]}"
  dpop
}                                                               # }}}1

# Usage: nap_vcs_log <dir> <n> [-v]
# Shows log; dies on failure.
function nap_vcs_log () {                                       # {{{1
  local dir="$1" n="$2" v="$3"
  local cmd=( git log -"$n" --reverse )
  [ "$v" == -v ] || cmd+=( --oneline )

  dpush "$dir"
    ohai "$( join ' ' "${cmd[@]}" )"
    try 'git log failed' "${cmd[@]}"
  dpop
}                                                               # }}}1

# --

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
