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

    # TODO
    def self.pretty_dot_hash(h, w = 29, pre = [])
      f = ->(p,v) { sprintf "%-#{w}s : %s", p*'.', v }
      h.map do |k,v|
        p = pre + [k]
        v.is_a?(Hash) ? pretty_dot_hash(v, w, p) : f[p,v]
      end*"\n"
    end

    # delete files if they exist; ohai (if any exist)
    def self.rm_if_exists(*files)
      if !(fs = files.select { |x| OU::FS.exists? x }).empty?
        OU.ohai "rm #{fs*' '}"; fs.each { |x| File.delete x }
      end
    end

    OU.link_mod_method OU::Term, :colour  , self, :col
    OU.link_mod_method OU::Term, :colour_e, self, :cole

  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
