# --                                                            ; {{{1
#
# File        : napp/util.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-25
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'obfusk/util/all'

require 'optparse'
require 'pathname'

module Napp

  OU = Obfusk::Util

  module Util

    OU.link_mod_method OU::Term, :colour  , self, :col
    OU.link_mod_method OU::Term, :colour_e, self, :cole

  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
