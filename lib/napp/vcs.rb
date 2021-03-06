# --                                                            ; {{{1
#
# File        : napp/vcs.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-25
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp

  module VCSs; end

  OU.require_all 'napp/vcss'

  module VCS

    # get vcs submodule
    def self.get(vcs)
      which[vcs] or raise OU::Valid::ArgumentError,
        "no such vcs: #{vcs}"
    end

    # vcs submodules
    def self.which
      OU.submodules Napp::VCSs
    end

  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
