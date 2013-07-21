# --                                                            ; {{{1
#
# File        : napp/daemon.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-21
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/cfg'
require 'napp/util'

module Napp; module Daemon

  class StatError < RuntimeError; end

  # --

  # NB: use napp-daemon w/ file_app_stat.

  # def self.start
  # end

  # def self.stop
  # end

  # --

  # wait n secs; show message, dots, OK; die if process isn't running
  def self.wait!(cfg, n)                                        # {{{1
    if n > 0
      OU.onow 'Waiting', "#{n} seconds"
      n.times { sleep 1; print '.'; STDOUT.flush }
      puts
    end
    s = stat(cfg, :die)[:status]
    if s == :running
      OU.onow 'OK'
    else
      OU.odie! "process is not running; status: #{s}", log: cfg.logger
    end
  end                                                           # }}}1

  # --

  # get status from statfile (or nil if no file); see napp-daemon
  # @raise StatError if no statfile and die
  # @raise StatError if unexpected data is encountered
  def self.stat(cfg, die = false)                               # {{{1
    f = Cfg.file_app_stat cfg
    if OU::FS.exists? f
      d = File.read f; l = x.split
      case l.first
      when 'spawning'   ; { status: :spawning }
      when 'running'    ; { status: :running, pid: Integer(l[1]) }
      when 'stopped'    ; { status: :stopped, exit: Integer(l[1]) }
      when 'terminated' ; { status: :terminated, signal: l[1] }
      when 'exited'     ; { status: :exited }
      else raise StatError, "Unexpected statfile: #{d}"
      end
    else
      if die then raise StatError, 'No statfile' else nil end
    end
  end                                                           # }}}1

  # status + col(our) + age
  def self.info(cfg)                                            # {{{1
    sta = stat(cfg) || { status: :stopped, exit: nil }
    age = sta[:pid] ? OU::Process.age(sta[:pid]) : nil
    col = case sta[:status]
    when :spawning    ; :yel
    when :running     ; :lgn
    when :stopped     ; :lrd
    when :terminated  ; :lbl
    when :exited      ; :red
    end
    sta.merge col: col, age: age
  end                                                           # }}}1

  # coloured status
  def self.info_coloured(s)
    Util.col(s[:col]) + s[:status].to_s + Util.col(:non)
  end

  # extra status info (if available): age+pid or exitstatus
  def self.info_extra(s)                                        # {{{1
    if s[:pid]
      " (pid=#{s[:pid]} age=#{s[:age]})"
    elsif s[:exit]
      " (exitstatus=#{s[:exit]})"
    else
      ''
    end
  end                                                           # }}}1

  # --

  # quiet info: just running|stopped|dead
  def self.info_quiet(s)
    info_coloured s
  end

  # short info: quiet + extra
  def self.info_short(s)
    info_coloured(s) + info_extra(s)
  end

  # show verbose info
  def self.show_info_verbose(s)
    OU.onow 'Status', info_short(s)
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
