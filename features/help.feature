@announce @sandbox
Feature: napp help <command>

  Scenario: napp help bootstrap

    When  I run `napp help bootstrap`
    Then  it should pass with exactly:
      """
      Usage: napp bootstrap <name>

      """

  Scenario: napp help new
    When  I run `napp help new`
    Then  it should pass with exactly:

                                                                # {{{1
      """
      Usage: napp new <type> <name> <repo> [<opt(s)>]

      Options:
              --vcs VCS                    Version control system; default is git
          -b, --branch BRANCH              VCS branch; default is master

      To see type options, use: napp help new [<type>]

      Types: daemon
      VCSs: git

      """
                                                                # }}}1

  Scenario: napp help new daemon

    When  I run `napp help new daemon`
    Then  it should pass with exactly:

                                                                # {{{1
      """
      Usage: napp new <type> <name> <repo> [<opt(s)>]

      Options:
              --vcs VCS                    Version control system; default is git
          -b, --branch BRANCH              VCS branch; default is master

      daemon options:
          -s, --socket                     Listen on socket
          -p, --port PORT                  Listen on port
          -r, --run CMD                    Command to run app
          -B, --bootstrap CMD              Command(s) to bootstrap app;
                                           default is update command
          -u, --update CMD                 Command(s) to update app
          -l, --logdir [DIR]               Subdir of app with *.log files; optional;
                                           default DIR is log
          -P, --public [DIR]               Subdir of app with public files; optional;
                                           default DIR is public
          -w, --wait SECONDS               Wait a few seconds for the app to start;
                                           default is 7
              --server NAME                Nginx server_name; optional
              --[no-]validate-server       Validate server_name as ^[a-z0-9.*-]+|_$;
                                           default is true
              --[no-]ssl                   Nginx ssl; default is false
              --[no-]default-server        Nginx default_server; default is no
              --max-body-size SIZE         Nginx client_max_body_size;
                                           default is nginx default
              --[no-]proxy-buffering       Nginx proxy_buffering;
                                           default is nginx default

      Types: daemon
      VCSs: git

      """
                                                                # }}}1

  Scenario: napp help restart

    When  I run `napp help restart`
    Then  it should pass with exactly:
      """
      Usage: napp restart <name>

      """

  Scenario: napp help start

    When  I run `napp help start`
    Then  it should pass with exactly:
      """
      Usage: napp start <name>

      """

  Scenario: napp help status

    When  I run `napp help status`
    Then  it should pass with exactly:
      """
      Usage: napp status <name> [<opt(s)>]

      Options:
          -q, --quiet                      Quiet output: just (coloured) status
          -s, --short                      Short output: (coloured) status, extra info
          -v, --verbose                    Verbose output (default)

      """

  Scenario: napp help stop

    When  I run `napp help stop`
    Then  it should pass with exactly:
      """
      Usage: napp stop <name>

      """

  Scenario: napp help update

    When  I run `napp help update`
    Then  it should pass with exactly:
      """
      Usage: napp update <name>

      """

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
