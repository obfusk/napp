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

require 'io/console'

module Napp

  class Error < RuntimeError; end

  module Util

    class SysError < Error; end

    # --

    # some ansi escape colours
    COLOURS = {                                                 # {{{1
      non:  "\e[0m",
      red:  "\e[1;31m",
      grn:  "\e[1;32m",
      blu:  "\e[1;34m",
      whi:  "\e[1;37m",
    }                                                           # }}}1

    # some simple validations; false positives; no funny chars
    VALIDATE = {                                                # {{{1
      num:  %r{[0-9]+},
      word: %r{[a-z0-9_-]+},
      host: %r{[a-z0-9.*-]+|_},
      url:  %r{[a-z0-9A-Z@.:/_-]+},
    }                                                           # }}}1

    # --

    # nil if x is .empty?, x otherwise
    def self.empty_as_nil(x)
      x && x.empty? ? nil : x
    end

    # get submodules as hash
    # e.g. submodules(Foo) -> { 'bar' => Foo::Bar, ... }
    def self.submodules(mod)                                    # {{{1
      Hash[ mod.constants \
            .map { |x| [x.downcase.to_s, mod.const_get(x)] } \
            .select { |k,v| v.class == Module } ]
    end                                                         # }}}1

    # --

    # info message; "==> <msg>" w/ colours
    def self.ohai(msg)
      puts col(:blu) + '==>' + col(:whi) + ' ' + msg + col(:non)
    end

    # error message + log; "<label>: <msg>" w/ colours
    def self.onoe(msg, cfg, label = 'Error')
      puts col(:red) + label + col(:non) + ': ' + msg
      olog cfg, "#{label}: #{msg}"
    end

    # warning message (onoe w/ label 'Warning')
    def self.opoo(msg, cfg)
      onoe msg, cfg, 'Warning'
    end

    # onoe + exit
    def self.odie(*args)
      onoe *args; exit 1
    end

    # write message(s) to log file(s)
    def self.olog(cfg, *msgs)                                   # {{{1
      name  = cfg[:name]
      hdr   = "[#{now}][nap#{ name ? " (#{name})" : '' }]"
      msgs.each do |m|
        cfg[:logfiles].each do |l|
          File.open(l, 'a') { |f| f.puts "#{hdr} #{m}" }
        end
      end
      nil
    end                                                         # }}}1

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

    # print msg to stderr and exit
    def self.die!(msg)
      STDERR.puts msg; exit 1
    end

    # does file/dir or symlink exists?
    def self.exists?(path)
      File.exists?(path) || File.symlink?(path)
    end

    # write pid to file
    def self.mkpid(file, pid)
      File.open(file, 'w') { |f| f.puts pid }
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
