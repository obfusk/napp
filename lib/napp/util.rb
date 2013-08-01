# --                                                            ; {{{1
#
# File        : napp/util.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-01
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

    # config in "foo.bar : value1\nbaz.qux : value2" format
    def self.pretty_config(h, opts = {})                        # {{{1
      w = opts[:width] || 29; i = opts[:indent] || ''
      p = opts[:path] || []
      f = ->(x,v) { sprintf "%s%-#{w}s : %s", i, x*'.', v }
      h.map do |k,v|
        p2 = p + [k]; o2 = opts.merge path: p2
        v.is_a?(Hash) ? pretty_config(v, o2) : f[p2,v]
      end * "\n"
    end                                                         # }}}1

    # delete files if they exist; ohai (if any exist)
    def self.rm_if_exists(*files)
      if !(fs = files.select { |x| OU::FS.exists? x }).empty?
        OU.ohai "rm #{fs*' '}"; fs.each { |x| File.delete x }
      end
    end

    # --

    OU.link_mod_method OU::Term, :colour  , self, :col
    OU.link_mod_method OU::Term, :colour_e, self, :cole

  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
