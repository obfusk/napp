desc 'Run specs'
task :spec do
  sh 'rspec -c'
end

desc 'Run specs verbosely'
task 'spec:verbose' do
  sh 'rspec -cfd'
end

desc 'Run specs verbosely, view w/ less'
task 'spec:less' do
  sh 'rspec -cfd --tty | less -R'
end

desc 'Check for warnings'
task :warn do
  libs = (['lib'] + Dir['deps/*/lib']).map { |x| "-I #{x}" } *' '
  Dir['lib/**/*.rb'].each do |x|
    name = x.sub(/^lib\//,'').sub(/\.rb$/,'')
    sh "ruby -w #{libs} -r #{name} -e ''"
  end
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
