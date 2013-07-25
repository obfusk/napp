# --                                                            ; {{{1
#
# File        : _sandbox.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-25
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'obfusk/util/os'

require 'erb'
require 'fileutils'
require 'tmpdir'

module Napp; module Spec__

  class Sandbox                                                 # {{{1
    NAPP_YML_ERB = 'spec/_cfg/napp.yml.erb'

    def setup
      @home = Obfusk::Util::OS.home
      @sand = ".napp-sandbox-#{Obfusk::Util::OS.now '%s'}"
      @apps = "#{@sand}/apps"
      @log  = "#{@sand}/log"
      @cfg  = "#{@sand}/cfg"
      @temp = Dir.mktmpdir
      File.symlink @temp, "#{@home}/#{@sand}"
      [@apps,@log,@cfg].each do |x|
        FileUtils.mkdir_p "#{@home}/#{x}"
      end
      _process_napp_yml_erb
    end

    def teardown
      FileUtils.remove_entry_secure @temp
      File.unlink "#{@home}/#{@sand}"
    end

    def _process_napp_yml_erb
      File.write "#{@home}/#{@cfg}/napp.yml",
        ERB.new(File.read(NAPP_YML_ERB)).result(binding)
    end
  end                                                           # }}}1

end; end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
