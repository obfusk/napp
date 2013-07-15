# --                                                            ; {{{1
#
# File        : napp/util.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-14
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'etc'
require 'fileutils'
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
    def self.invalid!(msg)
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
      x.to_s.match /^(#{rx})$/ or invalid! "invalid #{name}"
    end

    # --

    # new struct w/ fields and optional block to be class eval'd
    def self.struct(*fields, &b)                                # {{{1
      Class.new(Struct.new(*fields.map(&:to_sym))) do
        # init w/ hash
        def initialize(h = {})
          h.each { |k,v| self[k] = v }
        end
        unless method_defined? :to_h
          # convert to hash (ruby 2 has this already)
          def to_h
            Hash[each_pair.to_a]
          end
        end
        # convert to hash w/ string keys
        def to_str_h
          Hash[to_h.map { |k,v| [k.to_s,v] }]
        end
        self.class_eval &b if b
      end
    end                                                         # }}}1

    # hash to struct
    def self.a_struct(h = {})
      Struct.new(*h.keys).new(*h.values)
    end

    # --

    # info message; "==> <msg>" w/ colours
    def self.ohai(msg)
      puts col(:blu) + '==> ' + col(:whi) + msg + col(:non)
    end

    # info message; "==> <msg>: <what>" w/ colours
    def self.onow(msg, *what)
      puts col(:grn) + '==> ' + col(:whi) + msg + col(:non) +
        (what.empty? ? '' : _owhat(what))
    end

    # (helper for onow)
    def self._owhat(what)
      ': ' + what.map { |x| col(:grn) + x + col(:non) } *', '
    end

    # error message + log; "<label>: <msg>" w/ colours
    def self.onoe(cfg, msg, label = 'Error')
      STDERR.puts cole(:red) + label + cole(:non) + ': ' + msg
      Log.olog cfg, "#{label}: #{msg}"
    end

    # warning message (onoe w/ label 'Warning')
    def self.opoo(cfg, msg)
      onoe cfg, msg, 'Warning'
    end

    # onoe/die!
    def self.odie(*args)
      onoe *args; die!
    end

    # --

    # colour code (or '' if not tty)
    def self.col(x, what = :out)
      tty?(what) ? COLOURS.fetch(x) : ''
    end

    # colour code for STDERR
    def self.cole(x)
      col(x, :err)
    end

    # terminal columns (cached)
    def self.cols
      @cols ||= %x[ TERM=${TERM:-dumb} tput cols ].to_i
    end

    # is STDOUT (or STDERR) a tty?
    def self.tty?(what = :out)
      (what == :out ? STDOUT : STDERR).isatty
    end

    # --

    # home dir of (current) user
    def self.home(user = nil)
      user ? Etc.getpwnam(user).dir : Dir.home
    end

    # user name
    def self.user
      Etc.getlogin
    end

    # --

    # helper for {,u}die!
    def self._die_msgs(msgs)
      msgs.each { |m| STDERR.puts "Error: #{m}" }
    end

    # prints msgs to stderr and dies
    def self.die!(*msgs)
      _die_msgs msgs; exit 1
    end

    # prints msgs to stderr and dies with usage
    def self.udie!(usage, *msgs)
      _die_msgs msgs; STDERR.puts "Usage: #{usage}"; die!
    end

    # --

    # does file/dir or symlink exists?
    def self.exists?(path)
      File.exists?(path) || File.symlink?(path)
    end

    # mkdir_p + ohai
    def self.mkdir_p(*paths)
      ohai "mkdir -p #{paths*' '}"
      FileUtils.mkdir_p paths
    end

    # current time ('%F %T')
    def self.now(fmt = '%F %T')
      Time.now.strftime fmt
    end

    # prompt for line; optionally hide input
    def self.prompt(prompt, hide = false)
      print prompt; STDOUT.flush
      line = hide ? STDIN.noecho { |i| i.gets } .tap { puts } : gets
      line && line.chomp
    end

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

    # ohai + run command
    def self.run(*args)
      ohai args*' '; sys *args
    end

  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
