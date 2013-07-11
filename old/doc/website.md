nap is a configurable and extensible set of tools and templates that
makes it easier to manage and deploy web applications.

  * Have new apps running in seconds.
  * Get a quick overview of running apps.
  * Update an app in seconds with a single command.
  * Allow developers to have their apps updated automatically when
    they push their code to the server.

--&gt;
[README][readme],
[The ruby type][t-ruby],
[The clojure type][t-clj],
[My server setup][my-srv]

<br/>

### Adding an app

    $ nap new hello ruby https://github.com/obfusk/nap-hello.git \
      ruby.port=3001
    $ nap bootstrap hello
    $ nap start hello

### Screenshots

[nap new/bootstrap/start][i-new] <br/>
![nap new/bootstrap/start][i-new]

[naps][i-naps] <br/>
![naps][i-naps]

[push][i-push] <br/>
![push][i-push]

<br/>

<small>
Copyright (C) 2012  Felix C. Stegerman  --  2012-08-17  --  v0.0.0
</small>

[readme]: https://github.com/obfusk/nap#readme
[t-ruby]: https://github.com/obfusk/nap/blob/master/doc/type-ruby
[t-clj]:  https://github.com/obfusk/nap/blob/master/doc/type-clj
[my-srv]: https://github.com/obfusk/nap/blob/master/doc/my-server

[i-new]:  https://raw.github.com/obfusk/nap-misc/master/img/new_boot_start.png
[i-naps]: https://raw.github.com/obfusk/nap-misc/master/img/naps.png
[i-push]: https://raw.github.com/obfusk/nap-misc/master/img/push.png
