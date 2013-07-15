# --                                                            ; {{{1
#
# File        : napp/daemon.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-15
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/cfg'
require 'napp/log'
require 'napp/util'

module Napp; module Daemon

  # rx = /^(SIG[A-Z]+)\s+/
  # x.match(rx) ? x.sub(rx, '') : x

  # --

  # get pid; returns pid or false
  def self.get_pid(cfg)
    f = Cfg.file_app_pid(cfg)
    Util.exists?(f) ? Integer(File.read(f)) : false
  end

  # write pid
  def self.save_pid(cfg, pid)
    File.write Cfg.file_app_pid(cfg), "#{pid}\n"
  end

  # --

  # run block in app's app dir
  def self.in_app_app(cfg, &b)
    Dir.chdir Cfg.dir_app_app(cfg), &b
  end

  # wait n secs; shows message + dots + OK; dies if process is dead
  def self.wait!(cfg, pid, n)                                   # {{{1
    if n > 0
      Util.onow 'Waiting', "#{n} seconds"
      n.times { sleep 1; print '.'; STDOUT.flush }
      puts
    end
    if Util.alive? pid
      Util.onow 'OK'
    else
      Util.odie cfg, 'process died'
    end
  end                                                           # }}}1

  # --

  # status + col(our) + age + pid
  def self.info(pid)                                            # {{{1
    sta = status pid
    col, wha, run = case sta
    when :stopped ; [:blu, sta     , false]
    when :dead    ; [:red, sta     , false]
    else            [:grn, :running, true ]
    end
    age = run ? Util.process_age(sta) : nil
    { col: col, status: wha, age: age, pid: pid, run: run }
  end                                                           # }}}1

  # status: :stopped, pid, or :dead
  def self.status(pid)
    !pid ? :stopped : Util.alive?(pid) ? pid : :dead
  end

  # --

  # coloured status
  def self.info_coloured(s)
    Util.col(s[:col]) + s[:status].to_s + Util.col(:non)
  end

  # extra status info: age + pid
  def self.info_extra(s)
    s[:run] ? " (age=#{s[:age]} pid=#{s[:pid]})" : ''
  end

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
    Util.onow 'Status', info_short(s)
  end

  # --

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
