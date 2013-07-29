require File.expand_path('../lib/napp/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'napp'
  s.homepage    = 'https://github.com/obfusk/nap'
  s.summary     = 'nightmare(less) application platform'

  s.description = <<-END.gsub(/^ {4}/, '')
    nightmare(less) application platform

    ...
  END

  s.version     = Napp::VERSION
  s.date        = Napp::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.license     = 'GPLv2'

  s.executables = %w{ napp napp-daemon }                        # TODO
  s.files       = %w{ .yardopts README.md Rakefile } \
                + %w{ napp.gemspec } \
                + Dir['{lib,spec}/**/*.rb']                     # TODO

  s.add_runtime_dependency 'eft'
  s.add_runtime_dependency 'obfusk-util'

  s.add_development_dependency 'aruba'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

  s.required_ruby_version = '>= 1.9.1'
end
