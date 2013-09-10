# --                                                            ; {{{1
#
# File        : features/step_definitions/misc.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-09-10
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

Then(/^the last stdout should match upd-cmds "(.*)":$/) do |c,e|
  cs = c.split(/\s*,\s*/).map { |x| "==> #{x}[^\\\\n]*(\n.*)?" }
  e2 = e.sub /UPDATE_CMDS/, cs*"\n"
  assert_matching_output e2, last_process.stdout
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
