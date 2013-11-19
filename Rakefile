require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

file 'pslm-0.0.0.gem' => Dir['bin/*.rb']+Dir['lib/*.rb']+Dir['lib/pslm/*.rb'] do
  `gem build pslm.gemspec`
end

task :gem => ['pslm-0.0.0.gem']
