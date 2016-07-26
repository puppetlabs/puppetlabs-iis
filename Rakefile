require 'rake'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'

require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

task :default => :unit

desc "Unit tests"
RSpec::Core::RakeTask.new(:unit) do |t,args|
  t.pattern     = 'spec/unit'
  t.rspec_opts  = '--color'
  t.verbose     = true
end

desc "Validate manifests, templates, and ruby files"
task :validate do
  Dir['manifests/**/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
  Dir['spec/**/*.rb','lib/**/*.rb'].each do |ruby_file|
    sh "ruby -c #{ruby_file}" unless ruby_file =~ /spec\/fixtures/
  end
  Dir['templates/**/*.erb'].each do |template|
    sh "erb -P -x -T '-' #{template} | ruby -c"
  end
end

desc "Beaker namespace"
RSpec::Core::RakeTask.new('beaker:rspec:test:pe',:host) do |t,args|
  args.with_defaults({:host => 'default'})
  ENV['BEAKER_set'] = args[:host]
  t.pattern = 'spec/acceptance'
  t.rspec_opts = '--color'
  t.verbose = true
end

RSpec::Core::RakeTask.new('beaker:rspec:test:git',:host) do |t,args|
  args.with_defaults({:host => 'default'})
  ENV['BEAKER_set'] = args[:host]
  t.pattern = 'spec/acceptance'
  t.rspec_opts = '--color'
  t.verbose = true
end
