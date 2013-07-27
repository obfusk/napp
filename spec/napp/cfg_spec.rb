# --                                                            ; {{{1
#
# File        : napp/cfg_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-27
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

# TODO: load_app_config, in_app_app, read_*, save_* ???

require 'napp/cfg'

ex          = Napp__Spec::EXAMPLES
ou          = Obfusk::Util
cfg         = Napp::Cfg
ex_napp_yml = File.read "#{ex}/napp.yml"
ex_app_yml  = File.read "#{ex}/app.yml"
ex_type_yml = File.read "#{ex}/type.yml"

fake_cfg = cfg::All.new(                                        # {{{1
  nappcfg: 'NAPPCFG',
  global: cfg::Global.new(
    dirs: cfg::Dirs.new(
      apps: 'APPS', log: 'LOG', nginx: 'NGINX',
      app: cfg::AppDirs.new(app: 'APP', cfg: 'CFG', log: 'LOG',
                            run: 'RUN').freeze
    ).freeze
  ).freeze,
  name: cfg::app_name('foo').freeze
).freeze                                                        # }}}1

fake_cfg2 = ou.deepdup(fake_cfg)
fake_cfg2.global.dirs.nginx = '/NGINX'

describe 'napp/cfg' do

  context 'All' do                                              # {{{1
    it 'logger' do
      logs = []
      x = cfg::All.new log: ->(c) { ->(*msgs) { logs += msgs } }
      x.logger['foo']
      x.logger['bar', 'baz']
      expect(logs).to eq(%w{ foo bar baz })
    end
  end                                                           # }}}1

  context 'Name' do                                             # {{{1
    it 'join' do
      x = cfg::Name.new user: 'foo', app: 'bar-baz'
      expect(x.join).to eq('foo/bar-baz')
    end
    it 'safe join' do
      x = cfg::Name.new user: 'foo', app: 'bar-baz'
      expect(x.safe).to eq('foo_S_bar_D_baz')
    end
  end                                                           # }}}1

  context 'config' do                                           # {{{1
    it 'valid config' do
      expect {
        cfg.config(
          nappcfg: 'fake', global: 'fake', log: 'fake',
          name: 'fake', app: 'fake', type: 'fake'
        ) { |c| c.extra = 'fake' }
      } .to_not raise_exception
    end
    it 'invalid config' do
      expect {
        cfg.config(nappcfg: 'fake', global: 'fake', log: 'fake')
      } .to \
        raise_exception(ou::BetterStruct::IncompleteError,
                        /empty field/)
    end
  end                                                           # }}}1

  context 'nappcfg' do                                          # {{{1
    it 'env' do
      old = ENV['NAPPCFG']; ENV['NAPPCFG'] = 'test test test'
      begin
        expect(cfg.nappcfg).to eq('test test test')
      ensure
        ENV['NAPPCFG'] = old
      end
    end
    it 'default' do
      old = ENV['NAPPCFG']; ENV['NAPPCFG'] = cfg::DEFAULT_NAPPCFG
      begin
        expect(cfg.nappcfg).to eq(cfg::DEFAULT_NAPPCFG)
      ensure
        ENV['NAPPCFG'] = old
      end
    end
  end                                                           # }}}1

  context 'app_name' do                                         # {{{1
    it 'valid w/o user' do
      expect(cfg.app_name('foo').join).to eq("#{ou::OS.user}/foo")
    end
    it 'valid w/ user' do
      expect(cfg.app_name('foo/bar').join).to eq('foo/bar')
    end
    it 'invalid' do
      expect { cfg.app_name('foo!') } .to \
        raise_exception(ou::Valid::ValidationError, 'invalid name')
    end
  end                                                           # }}}1

  context 'dirs_app' do                                         # {{{1
    it 'dirs_app' do
      expect(cfg.dirs_app(fake_cfg) .all? { |x|
        x.start_with? "#{ou::OS.home}/APPS/foo"
      }).to be_true
    end
  end                                                           # }}}1

  context 'dir_app*' do                                         # {{{1
    it 'dir_app' do
      expect(cfg.dir_app(fake_cfg, 'some', 'dir')).to \
        eq("#{ou::OS.home}/APPS/foo/some/dir")
    end
    it 'dir_app_app' do
      expect(cfg.dir_app_app(fake_cfg, 'test')).to \
        eq("#{ou::OS.home}/APPS/foo/APP/test")
    end
    it 'dir_app_cfg' do
      expect(cfg.dir_app_cfg(fake_cfg, 'test')).to \
        eq("#{ou::OS.home}/APPS/foo/CFG/test")
    end
    it 'dir_app_log' do
      expect(cfg.dir_app_log(fake_cfg, 'test')).to \
        eq("#{ou::OS.home}/APPS/foo/LOG/test")
    end
    it 'dir_app_run' do
      expect(cfg.dir_app_run(fake_cfg, 'test')).to \
        eq("#{ou::OS.home}/APPS/foo/RUN/test")
    end
  end                                                           # }}}1

  context 'file_*' do                                           # {{{1
    it 'file_napp_yml' do
      expect(cfg.file_napp_yml(fake_cfg)).to eq('NAPPCFG/napp.yml')
    end
    it 'file_log' do
      expect(cfg.file_log(fake_cfg)).to eq('LOG/napp.log')
    end
    it 'dir_nginx' do
      expect(cfg.dir_nginx(fake_cfg)).to eq('NAPPCFG/NGINX')
      expect(cfg.dir_nginx(fake_cfg2)).to eq('/NGINX')
    end
    it 'file_app_cfg_app' do
      expect(cfg.file_app_cfg_app(fake_cfg)).to \
        eq("#{ou::OS.home}/APPS/foo/CFG/app.yml")
    end
    it 'file_app_cfg_type' do
      expect(cfg.file_app_cfg_type(fake_cfg)).to \
        eq("#{ou::OS.home}/APPS/foo/CFG/type.yml")
    end
    it 'file_app_log' do
      expect(cfg.file_app_log(fake_cfg)).to \
        eq("#{ou::OS.home}/APPS/foo/LOG/napp.log")
    end
    it 'file_app_stat' do
      expect(cfg.file_app_stat(fake_cfg)).to \
        eq("#{ou::OS.home}/APPS/foo/RUN/daemon.stat")
    end
    it 'file_app_sock' do
      expect(cfg.file_app_sock(fake_cfg)).to \
        eq("#{ou::OS.home}/APPS/foo/RUN/daemon.sock")
    end
  end                                                           # }}}1

  context 'load_global' do                                      # {{{1
    it 'load_global' do
      expect(cfg.load_global(ex_napp_yml).user).to eq('napp')
    end
  end                                                           # }}}1

  context 'load_app' do                                         # {{{1
    it 'load_app' do
      expect(cfg.load_app(nil, ex_app_yml).vcs).to eq('git')
    end
  end                                                           # }}}1

  context 'dump_app' do                                         # {{{1
    it 'dump_app' do
      expect(cfg.dump_app(cfg::All.new(
        app: cfg.load_app(nil, ex_app_yml)
      ))).to eq(ex_app_yml)
    end
  end                                                           # }}}1

  context 'load_type' do                                        # {{{1
    it 'load_type' do
      expect(cfg.load_type(
        cfg::All.new(extra: cfg::Extra.new(
          type_mod: Napp::Types::Ruby)), ex_type_yml
      ).port).to eq(8888)
    end
  end                                                           # }}}1

  context 'dump_type' do                                        # {{{1
    it 'dump_type' do
      expect(cfg.dump_type(cfg::All.new(
        type: cfg.load_type(
          cfg::All.new(extra: cfg::Extra.new(
            type_mod: Napp::Types::Ruby)), ex_type_yml
      )))).to eq(ex_type_yml)
    end
  end                                                           # }}}1

  context 'app_to_extra' do                                     # {{{1
    it 'app_to_extra' do
      expect(cfg.app_to_extra(
        cfg.load_app(nil, ex_app_yml)
      ).type_mod).to eq(Napp::Types::Ruby)
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
