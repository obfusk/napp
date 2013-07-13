# --                                                            ; {{{1
#
# File        : napp/cfg.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-13
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/util'

module Napp; module Cfg

  All     = Util.struct *%w{ global cmd app type extra }
  Global  = Util.struct *%w{ ... }
  App     = Util.struct *%w{ name type repo vcs branch }
  Extra   = Util.struct *%w{ type type_mod vcs_mod }

  # --

  def self.load_global
    nil
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
