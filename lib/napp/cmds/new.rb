# --                                                            ; {{{1
#
# File        : napp/cmds/new.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-13
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

  USAGE   = 'napp new <name> <type> <repo> [<opt(s)>]'
  HELP    = 'napp help new [<type>]'

  CmdCfg  = Util.struct *%w{ help }

  # parse opts, validate
  def self.prepare(cfg, name, type, repo, args)                 # {{{1
    Util.validate! name, Util::VALIDATE[:word], 'name'          # TODO
    Util.validate! type, Util::VALIDATE[:word], 'type'
    Util.validate! repo, Util::VALIDATE[:url] , 'repo'
    t     = Type.get type
    cmd   = CmdCfg.new help: false
    app   = Cfg::App.new name: name, type: type, repo: repo,
                  vcs: VCS::DEFAULT, branch: VCS::DEFAULT_BRANCH
    extra = Cfg::Extra.new type: type, type_mod: t
    cfg.cmd = cmd; cfg.app = app; cfg.extra = extra
    op    = opt_parser cfg
    as    = Util.parse_opts op, args
    as.empty? or raise Util::ArgError, 'too many arguments'
    cfg.extra.vcs_mod = VCS.get cfg.app.vcs
    t.validate! cfg
    nil
  end                                                           # }}}1

  # ... TODO ...
  def self.run(cfg, *args_)                                     # {{{1
    name, type, repo, *args = Util.args 'new', args_, 3, nil
    prepare cfg, name, type, repo, args

    # TODO {
    require 'yaml'
    puts Util.a_struct(app: cfg.app, type: cfg.type).to_yaml
    # } TODO
  end                                                           # }}}1

  # help message
  def self.help(cfg, *args_)                                    # {{{1
    type,     = Util.args 'help new', args_, 0, 1
    Util.validate! type, Util::VALIDATE[:word], 'type' if type
    t         = type && Type.get(type)
    cfg.cmd   = CmdCfg.new help: true
    cfg.extra = Cfg::Extra.new type: type, type_mod: t
    "Usage: #{ USAGE }\n\n" +
    opt_parser(cfg).help + "\n" +
    "Types: #{ Type.which.keys.sort.join ', ' }\n" +
    "VCSs: #{ VCS.which.keys.sort.join ', ' }\n"
  end                                                           # }}}1

  # option parser; extended by cfg.extra.type_mod.options
  def self.opt_parser(cfg)                                      # {{{1
    # TODO: napp modify --name= --repo= !?
    OptionParser.new 'Options:' do |o|
      o.on('--vcs VCS',
           'Version control system; ' +
           "default is #{VCS::DEFAULT}") do |x|
        cfg.app.vcs = x
      end
      o.on('--branch BRANCH',
           "VCS branch; default is #{VCS::DEFAULT_BRANCH}") do |x|
        cfg.app.branch = x
      end
      if t = cfg.extra.type_mod
        o.separator "\n#{cfg.extra.type} options:"
        t.options o, cfg
      else
        o.separator "\nTo see type options, use: #{HELP}"
      end
    end
  end                                                           # }}}1

end; end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
