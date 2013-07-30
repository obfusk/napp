# --                                                            ; {{{1
#
# File        : features/_steps/misc.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-30
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

When(/^I run `([^`]*)` with bash$/) do |cmd|
  run_simple "bash -c \"#{cmd}\"", false
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
