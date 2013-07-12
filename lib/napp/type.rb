# --                                                            ; {{{1
#
# File        : napp/type.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-12
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/util'

module Napp; module Type

  # type submodules
  def self.which
    Util.submodules Napp::Types
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
