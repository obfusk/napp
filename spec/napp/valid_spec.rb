# --                                                            ; {{{1
#
# File        : napp/valid_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-07-29
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2
#
# --                                                            ; }}}1

require 'napp/valid'

va = Napp::Valid
ve = Obfusk::Util::Valid::ValidationError

describe 'napp/valid' do

  context 'priviliged_port?' do                                 # {{{1
    it 'yes' do
      expect(va.priviliged_port? 1023).to be_true
    end
    it 'no' do
      expect(va.priviliged_port? 1024).to be_false
    end
  end                                                           # }}}1

  context 'port!' do                                            # {{{1
    it 'valid' do
      expect { va.port! 8888 } .to_not raise_error
    end
    it 'invalid (string)' do
      expect { va.port! '8888' } .to raise_error(ve, 'invalid port')
    end
    it 'invalid (too low)' do
      expect { va.port! 0 } .to raise_error(ve, 'invalid port')
    end
    it 'invalid (too high)' do
      expect { va.port! 65536 } .to raise_error(ve, 'invalid port')
    end
  end                                                           # }}}1

  context 'branch!' do                                          # {{{1
    it 'valid' do
      expect { va.branch! 'master' } .to_not raise_error
    end
    it 'invalid (empty)' do
      expect { va.branch! '' } .to raise_error(ve, 'invalid branch')
    end
    it 'invalid (!)' do
      expect { va.branch! 'foo!' } .to \
        raise_error(ve, 'invalid branch')
    end
  end                                                           # }}}1

  context 'type!' do                                            # {{{1
    it 'valid' do
      expect { va.type! 'daemon' } .to_not raise_error
    end
    it 'invalid (empty)' do
      expect { va.type! '' } .to raise_error(ve, 'invalid type')
    end
    it 'invalid (!)' do
      expect { va.type! 'foo!' } .to \
        raise_error(ve, 'invalid type')
    end
  end                                                           # }}}1

  context 'vcs!' do                                             # {{{1
    it 'valid' do
      expect { va.vcs! 'git' } .to_not raise_error
    end
    it 'invalid (empty)' do
      expect { va.vcs! '' } .to raise_error(ve, 'invalid vcs')
    end
    it 'invalid (space)' do
      expect { va.vcs! 'not git' } .to raise_error(ve, 'invalid vcs')
    end
  end                                                           # }}}1

  context 'max_body_size!' do                                   # {{{1
    it 'valid (0)' do
      expect { va.max_body_size! '0' } .to_not raise_error
    end
    it 'valid (100m)' do
      expect { va.max_body_size! '100m' } .to_not raise_error
    end
    it 'invalid (empty)' do
      expect { va.max_body_size! '' } .to \
        raise_error(ve, 'invalid max_body_size')
    end
    it 'invalid (m)' do
      expect { va.max_body_size! 'm' } .to \
        raise_error(ve, 'invalid max_body_size')
    end
    it 'invalid (1)' do
      expect { va.max_body_size! '1' } .to \
        raise_error(ve, 'invalid max_body_size')
    end
    it 'invalid (1k)' do
      expect { va.max_body_size! '1k' } .to \
        raise_error(ve, 'invalid max_body_size')
    end
  end                                                           # }}}1

  context 'path!' do                                            # {{{1
    it 'valid' do
      expect { va.path! 'foo', 'foo/bar/7/baz' } .to_not raise_error
    end
    it 'invalid (empty)' do
      expect { va.path! 'foo', '' } .to raise_error(ve, 'invalid foo')
    end
    it 'invalid (spaces)' do
      expect { va.path! 'foo', 'some/dir with spaces' } .to \
        raise_error(ve, 'invalid foo')
    end
    it 'invalid (//)' do
      expect { va.path! 'foo', 'foo//bar' } .to \
        raise_error(ve, 'invalid foo')
    end
    it 'invalid (foo/)' do
      expect { va.path! 'foo', 'foo/' } .to \
        raise_error(ve, 'invalid foo')
    end
    it 'invalid (/foo)' do
      expect { va.path! 'foo', '/foo' } .to \
        raise_error(ve, 'invalid foo')
    end
  end                                                           # }}}1

  context 'repo!' do                                            # {{{1
    it 'valid (ssh)' do
      expect { va.repo! 'git@github.com:foo/bar.git' } .to_not \
        raise_error
    end
    it 'valid (https)' do
      expect { va.repo! 'https://github.com/foo/bar.git' } .to_not \
        raise_error
    end
    it 'valid (path)' do
      expect { va.repo! '/some/dir/../foo_bar-baz.git' } .to_not \
        raise_error
    end
    it 'invalid (empty)' do
      expect { va.repo! '' } .to raise_error(ve, 'invalid repo')
    end
    it 'invalid (spaces)' do
      expect { va.repo! 'some/dir with spaces' } .to \
        raise_error(ve, 'invalid repo')
    end
    it 'invalid (!?)' do
      expect { va.repo! 'foo!/bar?' } .to \
        raise_error(ve, 'invalid repo')
    end
  end                                                           # }}}1

  context 'server!' do                                          # {{{1
    it 'valid (_)' do
      expect { va.server! '_' } .to_not raise_error
    end
    it 'valid (example.com)' do
      expect { va.server! 'example.com' } .to_not raise_error
    end
    it 'valid (foo.*)' do
      expect { va.server! 'foo.*' } .to_not raise_error
    end
    it 'valid (foo-bar.com)' do
      expect { va.server! 'foo-bar.com' } .to_not raise_error
    end
    it 'valid (number7.name)' do
      expect { va.server! 'number7.name' } .to_not raise_error
    end
    it 'invalid (empty)' do
      expect { va.server! '' } .to raise_error(ve, 'invalid server')
    end
    it 'invalid (spaces)' do
      expect { va.server! 'foo bar' } .to \
        raise_error(ve, 'invalid server')
    end
    it 'invalid (_)' do
      expect { va.server! 'foo_bar.com' } .to \
        raise_error(ve, 'invalid server')
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
