@announce @sandbox @slow @new
Feature: napp new daemon hello-{rb,clj} ...

  Scenario Outline: napp new daemon
    When  I run `napp new daemon <name> ../../repos/<repo>` with:
      | -p  | <port>    |
      | -r  | <run>     |
      | -u  | <update>  |
    Then  it should pass with regexp:
      """
      ==> Adding new app: \S+/<name>
      ==> mkdir -p( \S+sandbox\S+/apps/<name>\S*){5}
      ==> git clone -b master \S+/<repo> \S+sandbox\S+/apps/<name>/app
      .*
      ==> Saving: app\.yml, type\.yml
      ==> Done\.
      """
    Examples:
      | name      | repo                  | port  | run     | update  |
      | hello-rb  | napp-hello-sinatra    | 8888  | RACKUP  | BUNDLE  |
      | hello-clj | napp-hello-compojure  | 9999  | JAR     | UBERJAR |

# ...

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
