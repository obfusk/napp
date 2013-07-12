# --                                                            ; {{{1
#
# File        : napp/util.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-12
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Util

  # ...

  # --

  def self.type_module (x)
    types[_submodule_name(x)]
  end

  def self.vcs_module (x)
    vcss[_submodule_name(x)]
  end

  def self.types
    _submodules Napp::Types
  end

  def self.vcss
    _submodules Napp::Vcss
  end

  # --

  def self._submodule_name(x)
    x.capitalize.to_sym
  end

  def self._submodules(mod)
    Hash[ mod.constants \
          .map { |x| [x,mod.const_get(x)] } \
          .select { |k,v| v.class == Module } ]
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
