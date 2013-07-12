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

    # print msg to stderr and exit
    def self.die!(msg)
      STDERR.puts msg; exit 1
    end

    # does file/dir or symlink exists?
    def self.exists?(path)
      File.exists?(path) || File.symlink?(path)
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

    # --

    # nil if x is .empty?, x otherwise
    def empty_as_nil(x)
      x && x.empty? ? nil : x
    end

    # --

    # get submodules as hash
    # e.g. submodules(Foo) -> { 'bar' => Foo::Bar, ... }
    def self.submodules(mod)                                    # {{{1
      Hash[ mod.constants \
            .map { |x| [x.downcase.to_s, mod.const_get(x)] } \
            .select { |k,v| v.class == Module } ]
    end                                                         # }}}1

  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
