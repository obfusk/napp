@sandbox @napp
Feature: SANDBOX, NAPPCFG, napp, version, help

  Scenario: SANDBOX

    When  I run `echo $SANDBOX` with bash
    Then  it should succeed
    And   the last stdout should match:
      """
      \A(/\w+)+/.napp-sandbox-\d+\.\d+
      \Z
      """

  Scenario: NAPPCFG

    When  I run `echo $NAPPCFG` with bash
    Then  it should succeed
    And   the last stdout should match:
      """
      \A(/\w+)+/.napp-sandbox-\d+\.\d+/cfg
      \Z
      """

  Scenario: napp

    When  I run `napp`
    Then  it should succeed
    And   the last stdout should be:
      """
      Usage: napp { <command> [<arg(s)>] | help [<command>] | version }

      """

  Scenario: napp version

    When  I run `napp version`
    Then  it should succeed
    And   the last stdout should match:
      """
      \Anapp version \d+\.\d+\.\d+(\.SNAPSHOT)?
      \Z
      """

  Scenario: napp help

    When  I run `napp help`
    Then  it should succeed
    And   the last stdout should be:
      """
      Usage: napp { <command> [<arg(s)>] | help [<command>] | version }

      Commands: bootstrap, new, restart, start, status, stop, update

      """

  @fail
  Scenario: napp foo

    When  I run `napp foo`
    Then  the exit status should be 1
    And   the last stderr should be:
      """
      Error: no such subcommand: foo
      Usage: napp { <command> [<arg(s)>] | help [<command>] | version }

      """

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
