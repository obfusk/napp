@announce @sandbox
Feature: NAPPCFG, napp, napp version, napp help

  Scenario: NAPPCFG

    When  I run `echo $NAPPCFG` with bash
    Then  it should pass with regexp:
      """
      ^(/\w+)+/.napp-sandbox-\d+\.\d+/cfg$
      """

  Scenario: napp

    When  I run `napp`
    Then  it should pass with exactly:
      """
      Usage: napp { <command> [<arg(s)>] | help [<command>] | version }

      """

  Scenario: napp version

    When  I run `napp version`
    Then  it should pass with regexp:
      """
      ^napp version \d+\.\d+\.\d+(\.SNAPSHOT)?$
      """

  Scenario: napp help

    When  I run `napp help`
    Then  it should pass with exactly:
      """
      Usage: napp { <command> [<arg(s)>] | help [<command>] | version }

      Commands: bootstrap, new, restart, start, status, stop, update

      """

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
