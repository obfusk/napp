require File.expand_path('../lib/napp/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'napp'
  s.homepage    = 'https://github.com/obfusk/nap'
  s.summary     = 'nightmare(less) application platform'

  s.description = <<-END.gsub(/^ {4}/, '')
    ...
  END

  s.version     = Napp::VERSION
  s.date        = Napp::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.license     = 'GPLv2'

  s.executables = %w{ napp napps }
  s.files       = %w{ README.md napp.gemspec }\                 # TODO
                + Dir['lib/napp/**/*.rb']

  s.required_ruby_version = '>= 1.9.1'
end
