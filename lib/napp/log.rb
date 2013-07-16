# --                                                            ; {{{1
#
# File        : napp/log.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-16
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
    hdr = "[#{Util.now}][napp #{cfg.name.join}]"
    msgs.each do |m|
      cfg.global.logfiles.each { |l| Util.append l, "#{hdr} #{m}" }
      puts "-- [DEBUG] #{hdr} #{m}"                             # TODO
    end
    nil
  end                                                           # }}}1

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
