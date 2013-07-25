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

    # OU::Term.colour
    def self.col(*a)
      OU::Term.colour *a
    end

    # OU::Term.colour_e
    def self.cole(*a)
      OU::Term.colour_e *a
    end

  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
