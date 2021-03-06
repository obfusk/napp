# --                                                            ; {{{1
#
# File        : napp/log.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-31
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Log

  # write message(s) to log file(s)
  # TODO: napp-log
  def self.log(cfg, *msgs)                                      # {{{1
    hdr = "[#{OU::OS.now}][napp #{cfg.name.join}]"
    msgs.each do |m|
      cfg.global.logfiles.each { |l| OU::FS.append l, "#{hdr} #{m}" }
      $stderr.puts "-- [DEBUG] #{hdr} #{m}"                     # TODO
    end
    nil
  end                                                           # }}}1

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
