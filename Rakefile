libs = (['lib'] + Dir['deps/*/lib']).map { |x| "-I #{x}" } *' '
spec = libs + ' -I test/lib -r napp/spec/helper'

desc 'Run cucumber'
task :cuke do
  sh 'cucumber -fprogress'
end

desc 'Run cucumber verbosely'
task 'cuke:verbose' do
  sh 'cucumber'
end

desc 'Run cucumber verbosely, view w/ less'
task 'cuke:less' do
  sh 'cucumber -c | less -R'
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
  sh "ruby -w #{libs} -r napp/cfg #{reqs} -e ''"
end

desc 'Check for warnings in specs'
task 'warn:spec' do
  reqs = Dir['spec/**/*.rb'].sort.map { |x| "-r ./#{x}" } * ' '
  sh "ruby -w -r rspec #{spec} #{reqs} -e ''"
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

desc 'Pry w/ libs'
task :pry do
  sh "pry #{libs}"
end
