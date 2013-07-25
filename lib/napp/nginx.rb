# --                                                            ; {{{1
#
# File        : napp/nginx.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-25
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

module Napp; module Nginx

  DEFAULTS = {
    server: nil, ssl: nil, default_server: nil, max_body_size: nil,
    proxy_buffering: nil
  }

  NginxCfg  = OU.struct(*DEFAULTS.keys)
  DEF       = 'nginx default'

  # --

  # extends Cmd::New/type option parser; MODIFIES cfg
  def self.options(o, cfg, nginx)                               # {{{1
    d   = cfg.global.defaults['nginx']
    mbs = d['max_body_size'] || DEF
    pb  = d['proxy_buffering'].nil? ? DEF : d['proxy_buffering']
    sr  = d['validate_server_name']
    o.on('--server NAME', 'Nginx server_name; optional') do |x|
      nginx.server = x
    end
    o.on('--[no-]validate-server',
         "Validate server_name as ^#{Valid::SERVER.source}$;",
         "default is #{sr}") do |x|
      cfg.other[:nginx_validate_server] = x
    end
    o.on('--[no-]ssl', "Nginx ssl; default is #{d['ssl']}") do |x|
      nginx.ssl = x
    end
    o.on('--[no-]default-server',
         'Nginx default_server; default is no') do |x|
      nginx.default_server = x
    end
    o.on('--max-body-size SIZE', 'Nginx client_max_body_size;',
         "default is #{mbs}") do |x|
      nginx.max_body_size = x
    end
    o.on('--[no-]proxy-buffering', 'Nginx proxy_buffering;',
         "default is #{pb}") do |x|
      nginx.proxy_buffering = x
    end
  end                                                           # }}}1

  # validate nginx cfg; set defaults; MODIFIES cfg
  def self.prepare!(cfg, nginx)                                 # {{{1
    d = cfg.global.defaults['nginx']
    nginx.ssl = d['ssl'] if nginx.ssl.nil?
    nginx.max_body_size ||= d['max_body_size']
    nginx.proxy_buffering = d['proxy_buffering'] \
      if nginx.proxy_buffering.nil?
    cfg.other[:nginx_validate_server] = d['validate_server_name'] \
      if cfg.other[:nginx_validate_server].nil?
    if nginx.server
      Valid.server! nginx.server \
        if cfg.other[:nginx_validate_server]
      Valid.max_body_size! nginx.max_body_size \
        if nginx.max_body_size
      nginx
    else
      OU::Valid.invalid! 'invalid: ssl w/o server' if nginx.ssl
      OU::Valid.invalid! 'invalid: default_server w/o server' \
        if nginx.default_server
      OU::Valid.invalid! 'invalid: max_body_size w/o server' \
        if nginx.max_body_size
      OU::Valid.invalid! 'invalid: proxy_buffering w/o server' \
        if nginx.proxy_buffering
      false
    end
  end                                                           # }}}1

  # --

  # create nginx config
  # listen must be { socket: socket, name: name };
  #             or { host: host, port: port };
  #             or { port: port }
  # opts:
  #   public: dir, max_body_size: val
  #   ssl|default_server|proxy_buffering: true|false
  def self.config_(listen, server, logdir, opts = {})           # {{{1
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
    (opts[:max_body_size] ? <<-END .gsub(/^ {6}/, '') : '') +
        client_max_body_size #{opts[:max_body_size]};

    END
    (!opts[:proxy_buffering].nil? ? <<-END .gsub(/^ {6}/, '') : '') +
        proxy_buffering #{ opts[:proxy_buffering] ? 'on' : 'off' };

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
    t = cfg.type; n = cfg.type.nginx
    listen  = t.listen == :socket ?
      { socket: Cfg.file_app_sock(cfg), name: cfg.name.safe } :
      { port: t.port }
    server  = n.server
    logdir  = Cfg.dir_app_log cfg
    public  = t.public && Cfg.dir_app_app(cfg, t.public)
    opts    = { public: public, ssl: n.ssl,
                default_server: n.default_server,
                max_body_size: n.max_body_size,
                proxy_buffering: n.proxy_buffering }
    config_ listen, server, logdir, opts
  end                                                           # }}}1

  # save config
  def self.save_config(cfg)
    f = "#{cfg.name.safe}.conf"
    FileUtils.mkdir_p Cfg.dir_nginx(cfg)
    File.write Cfg.dir_nginx(cfg, f), config(cfg)
  end

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
