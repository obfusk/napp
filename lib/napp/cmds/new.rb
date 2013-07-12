# --                                                            ; {{{1
#
# File        : napp/cmds/new.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-12
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/type'
require 'napp/util'
require 'napp/vcs'

module Napp; module Cmds; module New

  USAGE = 'napp new <name> <type> <repo> [<opt(s)>]'
  HELP  = 'napp help new [<type>]'

  # ... TODO ...
  def self.run(name, type, repo, *args)                         # {{{1
    t     = Type.get type
    new   = Util.struct name: name, type: t, repo: repo,
              vcs: VCS::DEFAULT, branch: VCS::DEFAULT_BRANCH
    opts  = Util.struct new: new, type => nil
    op    = opt_parser t, opts
    as    = Util.parse_opts op, args
    as.empty? or raise ArgumentError, 'too many arguments'
    puts "TODO: new #{opts} #{as}"
  end                                                           # }}}1

  # help message
  def self.help(type = nil)                                     # {{{1
    t = type && Type.get(type)
    "Usage: #{ USAGE }\n\n" +
    opt_parser(t).help + "\n" +
    "Types: #{ Type.which.keys.sort.join ', ' }\n" +
    "VCSs: #{ VCS.which.keys.sort.join ', ' }\n"
  end                                                           # }}}1

  # option parser; extended by type.options
  def self.opt_parser(type, opts = nil)                         # {{{1
    OptionParser.new 'Options:' do |o|
      o.on('--vcs VCS', "Default: #{VCS::DEFAULT}") do |x|
        opts.new.vcs = x
      end
      o.on('--branch BRANCH',
           "Default: #{VCS::DEFAULT_BRANCH}") do |x|
        opts.new.branch = x
      end

      if type
        o.separator "\n#{Type.get_name type} options:"
        type.options o, opts
      else
        o.separator "\nTo see type options, use: #{HELP}"
      end
    end
  end                                                           # }}}1

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
