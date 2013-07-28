# --                                                            ; {{{1
#
# File        : napp/util_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-28
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/util'
require 'obfusk/util/spec'

require 'fileutils'
require 'tmpdir'

ou = Obfusk::Util
ut = Napp::Util

describe 'napp/util' do

  context 'rm_if_exists' do                                     # {{{1
    it 'existing' do
      Dir.mktmpdir do |dir|
        t = "#{dir}/testfile"; FileUtils.touch t
        expect(ou.capture_stdout do
          ut.rm_if_exists t, "#{dir}/nonexistent"
        end).to eq("==> rm #{t}\n")
        expect(File.exists? t).to be_false
      end
    end
    it 'non-existing' do
      Dir.mktmpdir do |dir|
        expect(ou.capture_stdout do
          ut.rm_if_exists "#{dir}/testfile", "#{dir}/nonexistent"
        end).to eq('')
      end
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
