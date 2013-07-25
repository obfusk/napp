# --                                                            ; {{{1
#
# File        : napp/vcss/git.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-25
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module VCSs; module Git

  CLONE = ->(r,d,b) { %w{ git clone -b } + [b,r,d] }
  PULL  = ->(b)     { %w{ git pull origin } + [b] }
  LOG   = ->(n,v)   { %w{ git log --reverse } + ["-#{n}"] +
                        (v ? [] : %w{ --oneline }) }

  # --

  # clone repo to dir (and checkout branch)
  def self.clone(repo, dir, branch)
    OU.chk_exit(CLONE[repo, dir, branch]) { |a| OU.ospawn_w(*a) }
  end

  # pull branch in dir
  def self.pull(dir, branch)
    OU.chk_exit(PULL[branch]) { |a| OU.ospawn_w(*a, chdir: dir) }
  end

  # show log in dir, n lines, optionally verbose, newest last
  def self.log(dir, n, verbose)
    OU.chk_exit(LOG[n,verbose]) { |a| OU.ospawn_w(*a, chdir: dir) }
  end

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
