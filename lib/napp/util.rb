# --                                                            ; {{{1
#
# File        : napp/util.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-13
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'etc'
require 'io/console'
require 'optparse'

module Napp

  class Error < RuntimeError; end

  module Util

    class ArgError < Error; end
    class CfgError < Error; end
    class SysError < Error; end
    class ValidationError < Error; end

    # --

    # some ansi escape colours
    COLOURS = {                                                 # {{{1
      non:  "\e[0m",
      red:  "\e[1;31m",
      grn:  "\e[1;32m",
      blu:  "\e[1;34m",
      whi:  "\e[1;37m",
    }                                                           # }}}1

    # --

    # validate #args in min..max (min.. if max=nil); returns args
    # @raise ArgError on out of bounds
    def self.args(what, args, min, max = min)                   # {{{1
      if args.length < min || (max && args.length > max)
        raise ArgError, "#{what} expected #{min}..#{max} arguments" +
                        ", got #{args.length}"
      end
      args
    end                                                         # }}}1

    # nil if x is .empty?, x otherwise
    def self.empty_as_nil(x)
      x && x.empty? ? nil : x
    end

    # @raise ValidationError
    def invalid!(msg)
      raise ValidationError, msg
    end

    # parse options, return remaining args
    def self.parse_opts(op, args)
      as = args.dup; op.parse! as; as
    end

    # load <dir>/* (by searching for <dir>/*.rb in $LOAD_PATH)
    # e.g. require_all('napp/types') ~> require 'napp/types/*'
    def self.require_all(dir)                                   # {{{1
      $LOAD_PATH.map { |x| Dir["#{x}/#{dir}/*.rb"] } .flatten \
        .map { |x| "#{dir}/" + File.basename(x, '.rb') } .uniq \
        .each { |x| require x }
    end                                                         # }}}1

    # get submodules as hash
    # e.g. submodules(Foo) -> { 'bar' => Foo::Bar, ... }
    def self.submodules(mod)                                    # {{{1
      Hash[ mod.constants \
            .map { |x| [x.downcase.to_s, mod.const_get(x)] } \
            .select { |k,v| v.class == Module } ]
    end                                                         # }}}1

    # validate value against regex
    # @raise ValidationError on no match
    def self.validate!(x, rx, name)
      x.match /^(#{rx})$/ || invalid! "invalid #{name}"
    end

    # --

    # new struct
    def self.struct(*fields)                                    # {{{1
      Class.new(Struct.new(*fields.map(&:to_sym))) do
        def initialize(h = {})
          h.each { |k,v| self[k] = v }
        end
        def to_h
          Hash[each_pair.to_a]
        end
      end
    end                                                         # }}}1

    # hash to struct
    def self.a_struct(h = {})
      Struct.new(*h.keys).new(*h.values)
    end

    # --

    # info message; "==> <msg>" w/ colours
    def self.ohai(msg)
      puts col(:blu) + '==>' + col(:whi) + ' ' + msg + col(:non)
    end

    # error message + log; "<label>: <msg>" w/ colours
    def self.onoe(msg, cfg, label = 'Error')
      puts col(:red) + label + col(:non) + ': ' + msg
      Log.olog cfg, "#{label}: #{msg}"
    end

    # warning message (onoe w/ label 'Warning')
    def self.opoo(msg, cfg)
      onoe msg, cfg, 'Warning'
    end

    # onoe + exit
    def self.odie(*args)
      onoe *args; exit 1
    end

    # --

    # colour code (or '' if not tty)
    def self.col(x)
      tty? ? COLOURS[x] : ''
    end

    # terminal columns (cached)
    def self.cols
      @cols ||= %x[ TERM=${TERM:-dumb} tput cols ].to_i
    end

    # is STDOUT a tty? (cached)
    def self.tty?
      @tty ||= STDOUT.isatty
    end

    # --

    # home dir of (current) user
    def self.dir_home(user = nil)
      user ? Etc.getpwnam(user).dir : Dir.home
    end

    # user name
    def self.user
      Etc.getlogin
    end

    # --

    # print msg to stderr and exit
    def self.die!(msg)
      STDERR.puts msg; exit 1
    end

    # prints msgs to stderr and dies with usage
    def self.fail!(usage, *msgs)
      msgs.each { |m| STDERR.puts "Error: #{m}" }
      die! "Usage: #{usage}"
    end

    # --

    # does file/dir or symlink exists?
    def self.exists?(path)
      File.exists?(path) || File.symlink?(path)
    end

    # current time ('%F %T')
    def self.now(fmt = '%F %T')
      Time.now.strftime fmt
    end

    # prompt for line; optionally hide input
    def self.prompt(prompt, hide = false)                       # {{{1
      STDOUT.print prompt; STDOUT.flush
      line = if hide
        l = STDIN.noecho { |i| i.gets }; STDOUT.puts; l
      else
        STDIN.gets
      end
      line && line.chomp
    end                                                         # }}}1

    # --

    # exec command
    # @raise SysError on ENOENT
    def self.exe(cmd, *args)                                    # {{{1
      begin
        exec [cmd, cmd], *args
      rescue Errno::ENOENT => e
        raise SysError,
          "failed to exec command #{ ([cmd] + args) }: #{e.message}"
      end
    end                                                         # }}}1

    # spawn command
    # @raise SysError on ENOENT
    def self.spw(cmd, *args)                                    # {{{1
      begin
        spawn [cmd, cmd], *args
      rescue Errno::ENOENT => e
        raise SysError,
          "failed to spawn command #{ ([cmd] + args) }: #{e.message}"
      end
    end                                                         # }}}1

    # run command
    # @raise SysError on failure
    def self.sys(cmd, *args)
      system [cmd, cmd], *args or raise SysError,
        "failed to run command #{ ([cmd] + args) } (#$?)"
    end

  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
