# --                                                            ; {{{1
#
# File        : napp/vcs.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-12
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/util'

module Napp; module VCS

  # vcs submodules
  def self.which
    Util.submodules Napp::VCSs
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
