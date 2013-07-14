# --                                                            ; {{{1
#
# File        : napp/vcss/git.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-12
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/util'

module Napp; module VCSs; module Git

  CLONE = ->(r,d,b) { %w{ git clone -b } + [b,r,d] }
  PULL  = ->(b)     { %w{ git pull origin } + [b] }
  LOG   = ->(n,v)   { %w{ git log --reverse } + ["-#{n}"] +
                        (v ? [] : %w{ --oneline }) }

  # --

  # clone repo to dir (and checkout branch)
  def self.clone(repo, dir, branch)
    Util.run *CLONE[repo, dir, branch]
  end

  # pull branch in dir
  def self.pull(dir, branch)
    Dir.chdir(dir) { Util.run *PULL[branch] }
  end

  # show log in dir, n lines, optionally verbose, newest last
  def self.log(dir, n, verbose)
    Dir.chdir(dir) { Util.run *LOG[n,verbose] }
  end

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
