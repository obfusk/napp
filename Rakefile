libs  = (['lib'] + Dir['deps/*/lib']).map { |x| "-I #{x}" } *' '
spec  = '-I test/lib -r napp/spec/helper'
cuke  = ENV['CUKE']

ENV['NAPPCFG']  = "#{Dir.pwd}/examples"
ENV['PATH']     = "#{Dir.pwd}/bin:#{ENV['PATH']}"
ENV['RUBYOPT']  = "#{ENV['RUBYOPT']} #{libs}"

desc 'Run all tests'
task test: [:cuke, :spec, :warn, 'warn:spec']

desc 'Run cucumber'
task :cuke do
  sh "cucumber -fprogress #{cuke}"
end

desc 'Run cucumber verbosely'
task 'cuke:verbose' do
  sh "cucumber #{cuke}"
end

desc 'Run cucumber verbosely, view w/ less'
task 'cuke:less' do
  sh "cucumber -c #{cuke} | less -R"
end

desc 'Cucumber step defs'
task 'cuke:steps' do
  sh 'cucumber -c -fstepdefs | less -R'
end

desc 'Run specs'
task :spec do
  sh "rspec #{spec} -c"
end

desc 'Run specs verbosely'
task 'spec:verbose' do
  sh "rspec #{spec} -cfd"
end

desc 'Run specs verbosely, view w/ less'
task 'spec:less' do
  sh "rspec #{spec} -cfd --tty | less -R"
end

desc 'Check for warnings'
task :warn do
  reqs = Dir['lib/**/*.rb'].sort.map do |x|
    '-r ' + x.sub(/^lib\//,'').sub(/\.rb$/,'')
  end * ' '
  c = "ruby -w -r napp/cfg #{reqs} -e '' 2>&1"
  puts c; x = %x[ #{c} ]
  puts '=== warnings ===', x unless x.empty?
  puts
end

desc 'Check for warnings in specs'
task 'warn:spec' do
  reqs = Dir['spec/**/*.rb'].sort.map { |x| "-r ./#{x}" } * ' '
  c = "ruby -w -r rspec #{spec} #{reqs} -e '' 2>&1"
  puts c; x = %x[ #{c} ]
  puts '=== spec warnings ===', x unless x.empty?
  puts
end

desc 'Generate docs'
task :docs do
  sh 'yardoc | cat'
end

desc 'List undocumented objects'
task 'docs:undoc' do
  sh 'yard stats --list-undoc'
end

desc 'Cleanup'
task :clean do
  puts 'Use make clean'
end

desc 'Build SNAPSHOT gem'
task :snapshot do
  v = Time.new.strftime '%Y%m%d%H%M%S'
  f = 'lib/napp/version.rb'
  sh "sed -ri~ 's!(SNAPSHOT)!\\1.#{v}!' #{f}"
  sh 'gem build napp.gemspec'
end

desc 'Undo SNAPSHOT gem'
task 'snapshot:undo' do
  sh 'git checkout -- lib/napp/version.rb'
end

desc 'Pry w/ env'
task :pry do
  sh 'pry'
end

desc 'Environment'
task :env do
  puts "export PATH='#{ENV['PATH']}'"
  puts "export NAPPCFG='#{ENV['NAPPCFG']}'"
  puts "export RUBYOPT='#{ENV['RUBYOPT']}'"
end
