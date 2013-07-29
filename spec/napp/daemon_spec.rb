# --                                                            ; {{{1
#
# File        : napp/daemon_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-29
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/cfg'
require 'napp/daemon'

ou  = Obfusk::Util
cfg = Napp::Cfg
dae = Napp::Daemon

fake_cfg = cfg::All.new(                                        # {{{1
  global: cfg::Global.new(
    commands: { 'aliases' => {
      'BUNDLE'    => 'bundle install',
      'RAILS_UPD' => %w{ _bundle_ _migrate_ _assets_ },
    } },
    dirs: cfg::Dirs.new(
      apps: 'APPS',
      app: cfg::AppDirs.new(app: 'APP', cfg: 'CFG', log: 'LOG',
                            run: 'RUN').freeze
    ).freeze
  ).freeze,
  name: cfg::app_name('foo').freeze
).freeze                                                        # }}}1

describe 'napp/daemon' do

  context 'flatten_cmds' do                                      # {{{1
    it 'flat' do
      expect(dae.flatten_cmds(fake_cfg, %w{ BUNDLE BUNDLE })).to \
        eq(['bundle install', 'bundle install'])
    end
    it 'nested' do
      expect(dae.flatten_cmds(fake_cfg, %w{ BUNDLE RAILS_UPD })).to \
        eq(['bundle install', '_bundle_', '_migrate_', '_assets_'])
    end
  end                                                           # }}}1

  context 'alias_cmd' do                                        # {{{1
    it 'w/ alias' do
      expect(dae.alias_cmd(fake_cfg, 'BUNDLE')).to \
        eq('bundle install')
    end
    it 'w/o alias' do
      expect(dae.alias_cmd(fake_cfg, 'FOO')).to eq('FOO')
    end
  end                                                           # }}}1

  context 'daemon_cmd' do                                       # {{{1
    it 'daemon_cmd' do
      expect(dae.daemon_cmd(
        fake_cfg, 'SIGFOO SHELL=sh foo -l ${PORT} "bar baz"',
        { 'PORT' => 8888 }
      )).to eq([
        'nohup', 'napp-daemon',
        "#{ou::OS.home}/APPS/foo/RUN/daemon.stat",
        'SIGFOO', 'sh', '-c', 'foo -l 8888 "bar baz"'
      ])
    end
  end                                                           # }}}1

  context 'info' do                                             # {{{1
    it 'info for spawning' do
      expect(dae.info(fake_cfg, { status: :spawning })).to \
        eq({ status: :spawning, col: :yel, age: nil })
    end
    it 'info for running' do
      expect(dae.info(fake_cfg, { status: :running })).to \
        eq({ status: :running, col: :lgn, age: nil })
    end
    it 'info for stopped' do
      expect(dae.info(fake_cfg, { status: :stopped })).to \
        eq({ status: :stopped, col: :lrd, age: nil })
    end
    it 'info for terminated' do
      expect(dae.info(fake_cfg, { status: :terminated })).to \
        eq({ status: :terminated, col: :lbl, age: nil })
    end
    it 'info for exited' do
      expect(dae.info(fake_cfg, { status: :exited })).to \
        eq({ status: :exited, col: :red, age: nil })
    end
  end                                                           # }}}1

  context 'info_coloured' do                                    # {{{1
    it 'no colours' do
      ou.capture_stdout {
        expect(dae.info_coloured status: 'FOO', col: :red).to \
          eq('FOO')
      }
    end
    it 'colours' do
      ou.capture_stdout(:tty) {
        expect(dae.info_coloured status: 'FOO', col: :red).to \
          eq("\e[0;31mFOO\e[0m")
      }
    end
  end                                                           # }}}1

  context 'info_extra' do                                       # {{{1
    it 'pid' do
      expect(dae.info_extra(
        status: 'FOO', age: '13:17', pid: 8888, daemon_pid: 9999
      )).to eq(' (age=13:17 pid=8888 daemon=9999)')
    end
    it 'exit' do
      expect(dae.info_extra(status: 'FOO', exit: 234)).to \
        eq(' (exitstatus=234)')
    end
  end                                                           # }}}1

  context 'info_*' do                                           # {{{1
    it 'info_quiet' do
      s = { status: 'FOO', col: :red }
      ou.capture_stdout(:tty) {
        expect(dae.info_quiet s).to eq(dae.info_coloured s)
      }
    end
    it 'info_short' do
      s = { status: 'FOO', col: :red, age: '13:17', pid: 8888,
            daemon_pid: 9999 }
      ou.capture_stdout(:tty) {
        expect(dae.info_short s).to \
          eq(dae.info_coloured(s) + dae.info_extra(s))
      }
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
