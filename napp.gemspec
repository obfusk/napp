require File.expand_path('../lib/napp/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'napp'
  s.homepage    = 'https://github.com/obfusk/nap'
  s.summary     = '...'

  s.description = <<-END.gsub(/^ {4}/, '')
    ...
  END

  s.version     = Napp::VERSION
  s.date        = Napp::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.license     = 'GPLv2'

# s.executables = %w{ napp }
  s.files       = %w{ README.md napp.gemspec }\ # TODO
                + Dir['lib/**/*.rb']

  s.required_ruby_version = '>= 1.9.1'
end
