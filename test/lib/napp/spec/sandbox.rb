# --                                                            ; {{{1
#
# File        : napp/spec/sandbox.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-27
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'obfusk/util/os'

require 'erb'
require 'fileutils'
require 'tmpdir'

module Napp__Spec

  class Sandbox                                                 # {{{1

    NAPP_YML_ERB = "#{EXAMPLES}/napp.yml.erb"

    # --

    def dir_sandbox (abs = false) _dir @sand, abs end
    def dir_apps    (abs = false) _dir @apps, abs end
    def dir_cfg     (abs = false) _dir @cfg , abs end
    def dir_log     (abs = false) _dir @log , abs end

    # --

    # setup: set @home, @sand/@apps/@cfg/@log (relative to @home), and
    # @temp; create tempdir + subdirs + symlink; turn erb into
    # napp.yml
    def setup                                                   # {{{2
      @home = Obfusk::Util::OS.home
      @sand = ".napp-sandbox-#{Obfusk::Util::OS.now '%s'}"
      @apps = "#{@sand}/apps"
      @cfg  = "#{@sand}/cfg"
      @log  = "#{@sand}/log"
      @temp = Dir.mktmpdir
      File.symlink @temp, "#{@home}/#{@sand}"
      [@apps, @cfg, @log].each do |x|
        FileUtils.mkdir_p "#{@home}/#{x}"
      end
      _process_napp_yml_erb
    end                                                         # }}}2

    # teardown: remove tempdir + symlink
    def teardown
      FileUtils.remove_entry_secure @temp
      File.unlink "#{@home}/#{@sand}"
    end

    # --

    def _dir(dir, abs) abs ? "#{@home}/#{dir}" : dir end

    # turn napp.yml.erb into napp.yml in sandbox
    def _process_napp_yml_erb
      File.write "#{@home}/#{@cfg}/napp.yml",
        ERB.new(File.read(NAPP_YML_ERB)).result(binding)
    end

  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
