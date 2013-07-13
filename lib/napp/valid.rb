# --                                                            ; {{{1
#
# File        : napp/valid.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-13
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/util'

module Napp; module Valid

  # NB: keep it simple: some false positives, nothing dangerous

  NUM     = %r{\d+}
  WORD    = %r{[a-z0-9_-]+}
  PATH    = %r{(#{WORD}/)*#{WORD}}
  SERVER  = %r{[a-z0-9.*-]+|_}
  URL     = %r{[a-z0-9A-Z@.:/_-]+}                              # TODO

  # --

  class << self
    %w{ type vcs branch }.each do |x|
      define_method "#{x}!" do |v|
        Util.validate! v, WORD, x
      end
    end
  end

  # validate repo
  def self.repo!(repo)
    Util.validate! repo, URL , 'repo'
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
