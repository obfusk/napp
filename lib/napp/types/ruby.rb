# --                                                            ; {{{1
#
# File        : napp/types/ruby.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-12
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Types; module Ruby

  # ...

  # extends Cmd::New option parser -- TODO
  def self.options(o, opts)                                     # {{{1
    opts.ruby = Util.struct foo: nil, bar: nil

    o.on('--foo FOO', '...') do |x|
      opts.ruby.foo = x
    end
    o.on('--bar BAR', '...') do |x|
      opts.ruby.bar = x
    end
  end                                                           # }}}1

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
