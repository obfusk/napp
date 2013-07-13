# --                                                            ; {{{1
#
# File        : napp/log.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-13
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/util'

module Napp; module Log

  # write message(s) to log file(s)
  # TODO: napp-log
  def self.olog(cfg, *msgs)                                     # {{{1
    name  = cfg.app.name
    hdr   = "[#{Util.now}][napp#{ name ? " (#{name})" : '' }]"
    msgs.each do |m|
      cfg.global.logfiles.each do |l|
        File.open(l, 'a') { |f| f.puts "#{hdr} #{m}" }
      end
    end
    nil
  end                                                           # }}}1

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
