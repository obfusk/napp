# --                                                            ; {{{1
#
# File        : napp/nginx.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-15
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/cfg'

module Napp; module Nginx

  # server: nil, ssl: nil,
  # proxy_buffering_off: nil

  # extends Cmd::New/type option parser; MODIFIES cfg
  def self.options(o, cfg)                                      # {{{1
    d   = cfg.global.defaults['nginx']
    mbs = d['max_body_size'] || '?'                             # TODO
    o.on('--server NAME', 'Nginx server_name; optional') do |x|
      cfg.type.nginx_server = x
    end
    o.on('--[no-]ssl', "Nginx w/ ssl; default is #{d['ssl']}") do |x|
      cfg.type.nginx_ssl = x
    end
    o.on('--[no-]default-server',
         'Nginx w/ default_server; default is no') do |x|
      cfg.type.nginx_default_server = x
    end
    o.on('--max-body-size SIZE',
         "Nginx client_max_body_size; default is #{mbs}") do |x|
      cfg.type.nginx_max_body_size = x
    end
  end                                                           # }}}1

  # validate type cfg; sets defaults; MODIFIES cfg
  def self.validate!(cfg)                                       # {{{1
    t = cfg.type
    d = cfg.global.defaults['nginx']
    t.nginx_ssl = d['ssl'] if t.nginx_ssl.nil?
    t.nginx_max_body_size ||= d['max_body_size']
    t.nginx_proxy_buffering_off = d['proxy_buffering_off'] \
      if t.nginx_proxy_buffering_off.nil?
    # ...
    if t.nginx_server
      Valid.server! t.nginx_server
      Valid.max_body_size! t.nginx_max_body_size
    else
      Util.invalid! 'invalid: ssl w/o server' if t.nginx_ssl
      Util.invalid! 'invalid: default_server w/o server' \
        if t.nginx_default_server
      Util.invalid! 'invalid: max_body_size w/o server' \
        if t.nginx_max_body_size
      # ...
    end
    # ...
  end                                                           # }}}1

  # --

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

  # create config using cfg
  def self.config(cfg)                                          # {{{1
    t       = cfg.type
    listen  = t.listen == :socket ?
      { socket: Cfg.file_app_sock(cfg), name: cfg.name.safe } :
      { port: t.port }
    server  = t.server
    logdir  = Cfg.dir_app_log cfg
    public  = t.public && Cfg.dir_app_app(cfg, t.public)
    opts    = { public: public, ssl: t.ssl,
                default_server: t.default_server }
    create_config(listen, server, logdir, opts)
  end                                                           # }}}1

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
