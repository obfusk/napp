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

require 'napp/cfg'
require 'napp/type'
require 'napp/util'
require 'napp/vcs'

module Napp; module Cmds; module New

  USAGE = 'napp new <name> <type> <repo> [<opt(s)>]'
  HELP  = 'napp help new [<type>]'

  Cfg   = Util.struct *%w{ info app type }
  Info  = Util.struct *%w{ help type t_name vcs }

  # parse opts, validate
  def self.prepare(name, type, repo, args)                      # {{{1
    t     = Type.get type
    info  = Info.new help: false, type: t, t_name: type, vcs: nil
    app   = Napp::Cfg::App.new name: name, type: type, repo: repo,
              vcs: VCS::DEFAULT, branch: VCS::DEFAULT_BRANCH
    opts  = Cfg.new info: info, app: app, type: nil
    op    = opt_parser opts
    as    = Util.parse_opts op, args
    as.empty? or raise ArgumentError, 'too many arguments'
    opts.info.vcs = VCS.get opts.app.vcs
    t.validate! opts
    opts
  end                                                           # }}}1

  # ... TODO ...
  def self.run(name, type, repo, *args)                         # {{{1
    opts = prepare name, type, repo, args
    require 'yaml'
    puts Util.a_struct(app: opts.app, type: opts.type).to_yaml
  end                                                           # }}}1

  # help message
  def self.help(type = nil)                                     # {{{1
    t = type && Type.get(type)
    o = Cfg.new info: Info.new(help: true, type: t, t_name: type)
    "Usage: #{ USAGE }\n\n" +
    opt_parser(o).help + "\n" +
    "Types: #{ Type.which.keys.sort.join ', ' }\n" +
    "VCSs: #{ VCS.which.keys.sort.join ', ' }\n"
  end                                                           # }}}1

  # option parser; extended by type.options
  def self.opt_parser(opts)                                     # {{{1
    OptionParser.new 'Options:' do |o|
      o.on('--vcs VCS',
           'Version control system; ' +
           "default is #{VCS::DEFAULT}") do |x|
        opts.app.vcs = x
      end
      o.on('--branch BRANCH',
           "VCS branch; default is #{VCS::DEFAULT_BRANCH}") do |x|
        opts.app.branch = x
      end
      if t = opts.info.type
        o.separator "\n#{opts.info.t_name} options:"
        t.options o, opts
      else
        o.separator "\nTo see type options, use: #{HELP}"
      end
    end
  end                                                           # }}}1

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
