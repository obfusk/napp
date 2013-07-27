# --                                                            ; {{{1
#
# File        : napp/nginx_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-27
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/cfg'
require 'napp/nginx'

ex  = Napp__Spec::EXAMPLES
ou  = Obfusk::Util
cfg = Napp::Cfg
ngi = Napp::Nginx

nex = ->(n) {
  File.read("#{ex}/nginx#{n}.conf") .gsub(/USER/, ou::OS.user) \
                                    .gsub(/HOME/, ou::OS.home)
}

fake_cfg = ->(t) {                                          # {{{1
  cfg::All.new(
    global: cfg::Global.new(
      dirs: cfg::Dirs.new(
        apps: 'APPS',
        app: cfg::AppDirs.new(app: 'APP', cfg: 'CFG', log: 'LOG',
                              run: 'RUN').freeze
      ).freeze
    ).freeze,
    type: ou.struct(*%w{ nginx listen port socket public })
      .new(t).freeze,
    name: cfg::app_name('foo').freeze
  ).freeze
}                                                               # }}}1

describe 'napp/nginx' do

  context 'config' do                                           # {{{1
    it 'config #1' do
      c = fake_cfg[{
        nginx: ngi::NginxCfg.new(
          server: 'foo.*', ssl: false, default_server: false,
          max_body_size: nil, proxy_buffering: nil
        ).freeze, port: 8888, listen: :port
      }]
      expect(ngi.config c).to eq(nex[1])
    end
    it 'config #2' do
      c = fake_cfg[{
        nginx: ngi::NginxCfg.new(
          server: 'foo.*', ssl: true, default_server: true,
          max_body_size: '10m', proxy_buffering: nil
        ).freeze, listen: :socket
      }]
      expect(ngi.config c).to eq(nex[2])
    end
    it 'config #3' do
      c = fake_cfg[{
        nginx: ngi::NginxCfg.new(
          server: 'foo.*', ssl: false, default_server: false,
          max_body_size: nil, proxy_buffering: false
        ).freeze, listen: :socket
      }]
      expect(ngi.config c).to eq(nex[3])
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
