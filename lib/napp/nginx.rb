# --                                                            ; {{{1
#
# File        : napp/nginx.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-14
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/cfg'

module Napp; module Nginx

  # create nginx config
  # listen must be { socket: socket, name: name };
  #             or { host: host, port: port };
  #             or { port: port }
  # opts: public: dir, ssl|default_server: true
  def self.create_config(listen, server, logdir, opts = {})     # {{{1
    host      = listen[:host] || 'localhost'
    default   = opts[:default_server] ? ' default_server' : ''
    ext_port  = opts[:ssl] ? '443 ssl' : '80'

    (listen[:socket] ? <<-END .gsub(/^ {6}/, '') : '') +
      upstream __#{listen[:name]}_server__ {
        server unix:#{listen[:socket]} fail_timeout=0;
      }

    END
    <<-END .gsub(/^ {6}/, '') +
      server {
        listen      #{ext_port}#{default};
        server_name #{server};

        access_log  #{logdir}/nginx-access.log;
        error_log   #{logdir}/nginx-error.log;

    END
    (opts[:public] ? <<-END .gsub(/^ {6}/, '') : '') +
        root        #{opts[:public]};
        try_files   $uri/index.html $uri.html $uri @app;

    END
    <<-END .gsub(/^ {6}/, '') +
        location #{ opts[:public] ? '@app' : '/' } {
    END
    (listen[:socket] ? <<-END .gsub(/^ {6}/, '') :
          proxy_set_header  X-Forwarded-For
                              $proxy_add_x_forwarded_for;
          proxy_set_header  X-Forwarded-Proto $scheme;
          proxy_set_header  Host              $http_host;
          proxy_redirect    off;
          proxy_pass        http://__#{listen[:name]}_server__;
    END
    <<-END .gsub(/^ {6}/, '')) +
          proxy_pass http://#{host}:#{listen[:port]};
    END
    <<-END .gsub(/^ {6}/, '')
        }
      }
    END
  end                                                           # }}}1

  # create + write config
  def self.write_config(cfg)                                    # {{{1
    t       = cfg.type
    listen  = t.listen == :socket ?
      { socket: Cfg.file_app_sock(cfg), name: cfg.name.safe } :
      { port: t.port }
    server  = t.server
    logdir  = Cfg.dir_app_log cfg
    public  = t.public && Cfg.dir_app_app(cfg, t.public)
    opts    = { public: public, ssl: t.ssl,
                default_server: t.default_server }
    File.write Cfg.file_app_cfg_nginx(cfg),
      create_config(listen, server, logdir, opts)
  end                                                           # }}}1

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
