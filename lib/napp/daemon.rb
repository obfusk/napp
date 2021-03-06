# --                                                            ; {{{1
#
# File        : napp/daemon.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-02
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Daemon

  class StatError < RuntimeError; end

  # --

  # run bootstrap command(s)
  def self.bootstrap(cfg, vars = {}, env = {})
    run_cmds cfg, cfg.type.bootstrap, vars, env
  end

  # run update command(s)
  def self.update(cfg, vars = {}, env = {})
    run_cmds cfg, cfg.type.update, vars, env
  end

  # --

  # process running? returns [alive, ok]
  def self.running?(cfg, s = nil)
    t = s || stat(cfg, :ok); [t[:alive], t[:ok]]
  end

  # show app status; how: :quiet|short|verbose
  def self.status(cfg, how)                                     # {{{1
    sta = info cfg
    case how
    when :quiet   ; puts info_quiet sta
    when :short   ; puts info_short sta
    when :verbose ; OU.onow 'Status', info_short(sta)
    end
  end                                                           # }}}1

  # --

  # start process w/ napp-daemon (if not running), wait a few seconds
  def self.start(cfg, opts = {})                                # {{{1
    nohup = opts.fetch :nohup, true ; n   = opts[:n] || 5
    vars  = opts[:vars] || {}       ; env = opts[:env] || {}
    sta   = stat cfg, :ok
    if sta[:alive]
      s = sta[:status]; p = sta[:pid] ? " pid=#{sta[:pid]}" : ''
      OU.opoo "process is running (status=#{s}#{p})"
    else
      now   = OU::OS.now; dir = Cfg.dir_app_app cfg
      cmd   = daemon_cmd cfg, alias_cmd(cfg, cfg.type.run),
                vars, nohup
      olog  = Cfg.dir_app_log cfg, 'daemon-stdout.log'
      elog  = Cfg.dir_app_log cfg, 'daemon-stderr.log'
      info  = "[ #{now} -- napp -- starting #{cfg.name.join} ... ]"
      OU::FS.append olog, info; OU::FS.append elog, info
      OU.onow 'ENV', *OU::Cmd.env_to_a(env) if !env.empty?
      OU.ospawn(*cmd, chdir: dir, env: env,
        out: [olog, 'a'], err: [elog, 'a'], in: '/dev/null')
      wait! cfg, :running, n
    end
  end                                                           # }}}1

  # stop napp-daemon
  def self.stop(cfg, opts = {})                                 # {{{1
    n = opts[:n] || 5; sta = stat cfg, :ok
    if !sta[:alive]
      OU.opoo "process is not running (status=#{sta[:status]})"
    else
      ::Process.kill 'SIGTERM', sta[:daemon_pid]
      wait! cfg, :terminated, n
    end
  end                                                           # }}}1

  # --

  # run command(s)
  def self.run_cmds(cfg, cmds, vars = {}, env = vars)           # {{{1
    cs  = flatten_cmds(cfg, cmds).map { |x| sh_var_cmd x, vars }
    dir = Cfg.dir_app_app cfg
    OU.onow 'ENV', *OU::Cmd.env_to_a(env) if !env.empty?
    cs.each do |c|
      OU.chk_exit(c) { |a| OU.ospawn_w(*a, chdir: dir, env: env) }
    end
  end                                                           # }}}1

  # flatten + alias commands
  def self.flatten_cmds(cfg, cmds)
    cmds.map { |x| alias_cmd cfg, x } .flatten
  end

  # lookup alias
  def self.alias_cmd(cfg, cmd)
    cfg.global.commands['aliases'][cmd] || cmd
  end

  # is alias?
  def self.alias?(cfg, cmd)
    cfg.global.commands['aliases'].has_key? cmd
  end

  # napp-daemon command
  def self.daemon_cmd(cfg, cmd, vars, nohup = true)
    c1 = sh_var_sig_cmd cmd, vars
    c2 = c1[:command]; sig = c1[:signal]
    c3 = ['napp-daemon', Cfg.file_app_stat(cfg), sig] + c2
    nohup ? OU::Cmd.nohup(*c3) : c3
  end

  # process killsig, pass on to sh_var_cmd
  # returns { command: [command, ...], signal: signal }
  def self.sh_var_sig_cmd(cmd, vars)
    c1 = OU::Cmd.killsig cmd; c2 = sh_var_cmd c1[:command], vars
    { command: c2, signal: c1[:signal] }
  end

  # process shell, set vars; returns [command, ...]
  def self.sh_var_cmd(cmd, vars = nil)
    c1 = OU::Cmd.shell cmd; sh = c1[:shell]
    c2 = vars ? OU::Cmd.set_vars(c1[:command], vars) : c1[:command]
    sh ? [sh, '-c', c2] : c2.split
  end

  # wait n secs; show message, dots, OK; die if process isn't what
  def self.wait!(cfg, what, n)                                  # {{{1
    if n > 0
      OU.onow 'Waiting', "#{n} seconds"
      n.times { sleep 1; print '.'; $stdout.flush }
      puts
    end
    s = stat(cfg, :die)[:status]
    if s == what
      OU.onow 'OK'
    else
      OU.odie! "process is not #{what} (status=#{s})", log: cfg.logger
    end
  end                                                           # }}}1

  # --

  # get status from statfile; see napp-daemon
  # @raise StatError if no statfile and nostat == :die
  # @raise StatError if unexpected data is encountered
  def self.stat(cfg, nostat)                                    # {{{1
    f = Cfg.file_app_stat cfg
    if OU::FS.exists? f
      d = File.read f; l = d.split
      case l.first
      when 'spawning'   ; { alive: true, status: :spawning,
                            ok: false }
      when 'running'    ; { alive: true, status: :running,
                            ok: true,
                            daemon_pid: Integer(l[1]),
                            pid:        Integer(l[2]) }
      when 'stopped'    ; { alive: false, status: :stopped,
                            ok: false,
                            exit: Integer(l[1]) }
      when 'terminated' ; { alive: false, status: :terminated,
                            ok: true, signal: l[1] }
      when 'exited'     ; { alive: false, status: :exited,
                            ok: false }
      else raise StatError, "Unexpected statfile: #{d}"
      end
    else
      case nostat
      when :die     ; raise StatError, 'No statfile'
      when :ok      ; { alive: false, status: :terminated,
                        ok: true, signal: nil }
      else            nostat
      end
    end
  end                                                           # }}}1

  # status + col(our) + age
  def self.info(cfg, s = nil)                                   # {{{1
    sta = s || stat(cfg, :ok)
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

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
