require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?
require 'rototiller'

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('relative')
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_single_quote_string_with_variables')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

desc 'Generate Beaker Host config'
rototiller_task :host_config do |t|
  t.add_env({:name => 'PLATFORM', :message => 'PLATFORM Must be set. For example "windows2012r2-64"'})
  hosts_file = "spec/acceptance/nodesets/#{ENV['PLATFORM']}.yml"
  t.add_command do |cmd|
    cmd.name = 'bundle exec beaker-hostgenerator'
    cmd.add_argument({:name => "#{ENV['PLATFORM']} > #{hosts_file}"})
  end
end

desc 'Executes acceptance tests'
rototiller_task :acceptance do |t|
  t.add_command(name: 'bundle exec rspec spec/acceptance')

  t.add_env do |env|
    env.name = 'PUPPET_INSTALL_TYPE'
    env.default = 'agent'
  end

  t.add_env do |env|
    env.name = 'PLATFORM'
    env.default = 'default'
  end

  t.add_env do|env|
    env.name = 'BEAKER_setfile'
    env.default = 'spec/acceptance/nodesets/' + ENV['PLATFORM'] + '.yml'
  end

  t.add_env do |env|
    env.name = 'BEAKER_keyfile'
    env.default = "#{ENV['HOME']}/.ssh/id_rsa-acceptance"
  end
end
