# --                                                            ; {{{1
#
# File        : napp/daemon.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-22
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

  # start process w/ napp-daemon (if not running), wait a few seconds
  def self.start(cfg, opts = {})                                # {{{1
    nohup = opts.fetch :nohup, true ; n   = opts[:n] || 7
    vars  = opts[:vars] || {}       ; sta = stat cfg, :stopped
    if sta[:alive]
      s = sta[:status]; p = sta[:pid] ? " pid=#{sta[:pid]}" : ''
      OU.opoo "process is running (status=#{s}#{p})", log: cfg.logger
    else
      now   = OU::OS.now; dir = Cfg.dir_app_app cfg
      cmd   = daemon_cmd cfg, OU.cfg.type.run, vars
      olog  = Cfg.dir_app_log cfg, 'daemon-stdout.log'
      elog  = Cfg.dir_app_log cfg, 'daemon-stderr.log'
      info  = "[ #{now} -- napp -- starting #{cfg.name.join} ... ]"
      onow 'Starting', cmd[:show]
      OU::FS.append olog, info; OU::FS.append elog, info
      OU.spawn cmd[:cmd], chdir: dir, out: [olog, 'a'],
                                      err: [elog, 'a']
      wait! cfg, n
    end
  end                                                           # }}}1

  # stop napp-daemon
  def self.stop(cfg)                                            # {{{1
    sta = stat cfg, :stopped
    if !sta[:alive]
      s = sta[:status]
      OU.opoo "process is not running (status=#{s})", log: cfg.logger
    else
      cmd = daemon_cmd cfg, OU.cfg.type.run, vars
      onow 'Stopping', cmd[:show]
      ::Process.kill 'SIGTERM', sta[:daemon_pid]
    end
  end                                                           # }}}1

  # --

  # napp-daemon command
  def self.daemon_cmd(cfg, cmd, vars)                           # {{{1
    cmd1  = command cmd, vars
    cmd2  = cmd1[:command]; sig = cmd1[:signal]
    cmd3  = nohup ? OU::Cmd.nohup(cmd2) : cmd2
    cmd4  = ['napp-daemon', Cfg.file_app_stat(cfg), sig] + cmd3
    { cmd: cmd4, show: cmd2*' ' }
  end                                                           # }}}1

  # process killsig, shell, set vars
  # returns { command: [command, ...], signal: signal }
  def self.command(cmd, vars)                                   # {{{1
    c1 = OU::Cmd.killsig cmd
    c2 = OU::Cmd.shell c1[:command]; sh = c2[:shell]
    c3 = OU::Cmd.set_vars c2[:command], vars
    c4 = sh ? [sh, '-c', c3] : c3.split
    { command: c4, signal: c1[:signal] }
  end                                                           # }}}1

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
      OU.odie! "process is not running (status=#{s})", log: cfg.logger
    end
  end                                                           # }}}1

  # --

  # get status from statfile; see napp-daemon
  # @raise StatError if no statfile and nostat == :die
  # @raise StatError if unexpected data is encountered
  def self.stat(cfg, nostat)                                    # {{{1
    f = Cfg.file_app_stat cfg
    if OU::FS.exists? f
      d = File.read f; l = x.split
      case l.first
      when 'spawning'   ; { alive: true, status: :spawning }
      when 'running'    ; { alive: true, status: :running,
                            daemon_pid: Integer(l[1]),
                            pid:        Integer(l[2]) }
      when 'stopped'    ; { alive: false, status: :stopped,
                            exit: Integer(l[1]) }
      when 'terminated' ; { alive: false, status: :terminated,
                            signal: l[1] }
      when 'exited'     ; { alive: false, status: :exited }
      else raise StatError, "Unexpected statfile: #{d}"
      end
    else
      case nostat
      when :die     ; raise StatError, 'No statfile'
      when :stopped ; { alive: false, status: :stopped, exit: nil }
      else            nostat
      end
    end
  end                                                           # }}}1

  # status + col(our) + age
  def self.info(cfg)                                            # {{{1
    sta = stat cfg, :stopped
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

  # extra status info (if available): age+pids or exitstatus
  def self.info_extra(s)                                        # {{{1
    if s[:pid]
      " (age=#{s[:age]} pid=#{s[:pid]} daemon=#{s[:daemon_pid]})"
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
