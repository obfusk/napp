# --                                                            ; {{{1
#
# File        : napp/valid.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-22
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/util'

module Napp; module Valid

  # NB: keep it simple: some false positives, nothing dangerous

  WORD    = %r{[a-zA-Z0-9_-]+}                                  # TODO
  PATH    = %r{(#{WORD}/)*#{WORD}}                              # TODO
  SERVER  = %r{[a-z0-9.*-]+|_}                                  # TODO
  URL     = %r{[a-zA-Z0-9@.:/_-]+}                              # TODO

  # --

  class << self
    %w{ branch type vcs }.each do |x|
      define_method "#{x}!" do |v|
        OU::Valid.validate! v, WORD, x
      end
    end
  end

  def self.max_body_size!(size)
    OU::Valid.validate! size, /^([0-9]+m|0)$/, 'max_body_size'
  end

  def self.port!(port)
    (1..65535).include?(port) || OU::Valid.invalid!('invalid port')
  end

  def self.port_priviliged?(port)
    port < 1024
  end

  def self.path!(name, path)
    OU::Valid.validate! path, PATH, name
  end

  def self.repo!(repo)
    OU::Valid.validate! repo, URL, 'repo'
  end

  def self.server!(server)
    OU::Valid.validate! server, SERVER, 'server'
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
