@sandbox @slow @commands
Feature: napp <command> ...

  Scenario Outline: napp new, bootstrap, ...
    When  I run `napp new daemon <name> ../../repos/<repo>` with:
      | -p  | <port>        |
      | -r  | <run>         |
      | -u  | <update>      |
      | -w  | <wait-start>  |
      | -W  | <wait-stop>   |
    Then  it should succeed
    And   the last stdout should match:
      """
      \A==> Adding new app: \w+/<name>
      ==> mkdir -p( \S+sandbox\S+/apps/<name>\S*){5}
      ==> git clone -b master \S+/<repo> \S+sandbox\S+/apps/<name>/app
      .*
      ==> Saving: app\.yml, type\.yml
      ==> Done\.
      \Z
      """
    When  I run `napp bootstrap <name>`
    Then  it should succeed
    And   the last stdout should match upd-cmds "<upd-cmds>":
      """
      \A==> Bootstrapping: \w+/<name>
      UPDATE_CMDS
      ==> Done\.
      \Z
      """
    When  I run `napp status <name>`
    Then  it should succeed
    And   the last stdout should match:
      """
      \A==> App: \w+/<name>
      ==> Status: terminated
      \Z
      """
    When  I run `napp start <name>`
    Then  it should succeed
    And   the last stdout should match:
      """
      \A==> Starting: \w+/<name>
      ==> ENV: PORT="<port>"
      ==> nohup napp-daemon \S+/apps/<name>/run/daemon.stat SIG\w+ <run-cmd>[^\n]*
      ==> Waiting: <wait-start> seconds
      \.{<wait-start>}
      ==> OK
      ==> Done\.
      \Z
      """
    When  I run `napp status <name>`
    Then  it should succeed
    And   the last stdout should match:
      """
      \A==> App: \w+/<name>
      ==> Status: running \(age=\d\d:\d\d pid=\d+ daemon=\d+\)
      \Z
      """
    When  I run `curl -s localhost:<port>`
    Then  it should succeed
    And   the last stdout should match:
      """
      \AHello World!
      The time is: \d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d

      - <repo>
      \Z
      """
    When  I run `napp restart <name>`
    Then  it should succeed
    And   the last stdout should match:
      """
      \A==> Restarting: \w+/<name>
      ==> Waiting: <wait-stop> seconds
      \.{<wait-stop>}
      ==> OK
      ==> ENV: PORT="<port>"
      ==> nohup napp-daemon \S+/apps/<name>/run/daemon.stat SIG\w+ <run-cmd>[^\n]*
      ==> Waiting: <wait-start> seconds
      \.{<wait-start>}
      ==> OK
      ==> Done\.
      \Z
      """
    When  I run `napp status <name>`
    Then  it should succeed
    And   the last stdout should match:
      """
      \A==> App: \w+/<name>
      ==> Status: running \(age=\d\d:\d\d pid=\d+ daemon=\d+\)
      \Z
      """
    When  I run `napp update <name>`
    Then  it should succeed
    And   the last stdout should match upd-cmds "<upd-cmds>":
      """
      \A==> Updating: \w+/<name>
      ==> Waiting: <wait-stop> seconds
      \.{<wait-stop>}
      ==> OK
      ==> git pull origin master
      .*
      UPDATE_CMDS
      ==> ENV: PORT="<port>"
      ==> nohup napp-daemon \S+/apps/<name>/run/daemon.stat SIG\w+ <run-cmd>[^\n]*
      ==> Waiting: <wait-start> seconds
      \.{<wait-start>}
      ==> OK
      ==> Done\.
      \Z
      """
    When  I run `napp status <name>`
    Then  it should succeed
    And   the last stdout should match:
      """
      \A==> App: \w+/<name>
      ==> Status: running \(age=\d\d:\d\d pid=\d+ daemon=\d+\)
      \Z
      """
    When  I run `napp stop <name>`
    Then  it should succeed
    And   the last stdout should match:
      """
      \A==> Stopping: \w+/<name>
      ==> Waiting: <wait-stop> seconds
      \.{<wait-stop>}
      ==> OK
      ==> Done\.
      \Z
      """
    When  I run `napp status <name>`
    Then  it should succeed
    And   the last stdout should match:
      """
      \A==> App: \w+/<name>
      ==> Status: terminated
      \Z
      """
    When  I run `curl -s localhost:<port>`
    Then  it should fail
    When  I run `napp info <name>`
    Then  it should succeed
    And   the last stdout should match:
      """
      \Aname                          : \w+/<name>
      app\.type                      : daemon
      app\.repo                      : \S+/<repo>
      app\.vcs                       : git
      app\.branch                    : master
      type\.type                     : daemon
      type\.listen                   : port
      type\.port                     : <port>
      type\.run                      : <run>
      type\.bootstrap                : \["<update>"\]
      type\.update                   : \["<update>"\]
      type\.logdir                   : false
      type\.public                   : false
      type\.wait_start               : <wait-start>
      type\.wait_stop                : <wait-stop>
      type\.nginx                    : false
      \Z
      """
    When  I run `napp run <name> echo OK`
    Then  it should succeed
    And   the last stdout should match:
      """
      \A==> App: \w+/<name>
      ==> echo OK
      OK
      ==> Done\.
      \Z
      """
    When  I run `napp run <name> TEST`
    Then  it should succeed
    And   the last stdout should match:
      """
      \A==> App: \w+/<name>
      ==> echo OK
      OK
      ==> pwd
      \S+sandbox\S+/apps/<name>/app
      ==> Done\.
      \Z
      """
    Examples:
      | name      | repo                  | port  | wait-start  | wait-stop | run     | update    | run-cmd                             | upd-cmds                                                                                                                                  |
      | hello-clj | napp-hello-compojure  | 10001 | 2           | 1         | JAR     | UBERJAR   | java -jar                           | lein uberjar                                                                                                                              |
      | hello-js  | napp-hello-express    | 10002 | 1           | 1         | COFFEE  | NPM       | bash -c NODE_ENV=production coffee  | npm install                                                                                                                               |
      | hello-py  | napp-hello-flask      | 10003 | 1           | 1         | VPY     | VENV_PIP  | venv python                         | bash -c test -e .venv, venv pip install                                                                                                   |
      | hello-rb  | napp-hello-sinatra    | 10004 | 1           | 1         | RACKUP  | BUNDLE    | bundle exec rackup                  | bundle install                                                                                                                            |
      | hello-ror | napp-hello-rails      | 10005 | 3           | 1         | RAILS   | RAILS_UPD | bundle exec rails                   | bundle install, bash -c RAILS_ENV=production bundle exec rake db:migrate, bash -c RAILS_ENV=production bundle exec rake assets:precompile |

# TODO: kill/fail, update; 2x new
# ...

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
