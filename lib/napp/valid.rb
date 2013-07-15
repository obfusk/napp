# --                                                            ; {{{1
#
# File        : napp/valid.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-15
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/util'

module Napp; module Valid

  # NB: keep it simple: some false positives, nothing dangerous

  NUM     = %r{[0-9]+}
  WORD    = %r{[a-zA-Z0-9_-]+}
  PATH    = %r{(#{WORD}/)*#{WORD}}
  SERVER  = %r{[a-z0-9.*-]+|_}
  URL     = %r{[a-zA-Z0-9@.:/_-]+}                              # TODO

  # --

  class << self
    %w{ branch type vcs }.each do |x|
      define_method "#{x}!" do |v|
        Util.validate! v, WORD, x
      end
    end
  end

  def self.max_body_size!(size)
    Util.validate! size, /^([0-9]+m|0)$/, 'max_body_size'
  end

  def self.path!(name, path)
    Util.validate! path, PATH, name
  end

  def self.port!(port)
    Util.validate! port, NUM, 'port'
  end

  def self.repo!(repo)
    Util.validate! repo, URL, 'repo'
  end

  def self.server!(server)
    Util.validate! server, SERVER, 'server'
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
