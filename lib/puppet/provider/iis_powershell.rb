require 'pathname'

# This is the base class on which other providers are based.
class Puppet::Provider::IIS_PowerShell < Puppet::Provider # rubocop:disable all
  require Pathname.new(__FILE__).dirname + '..' + '..' + 'puppet_x' + 'puppetlabs' + 'iis' + 'powershell_manager'
  require Pathname.new(__FILE__).dirname + '..' + '..' + 'puppet_x' + 'puppetlabs' + 'iis' + 'powershell_common'
  include PuppetX::IIS::PowerShellCommon

  def initialize(value = {})
    super(value)
    @original_values = if value.is_a? Hash
                         value.clone
                       else
                         {}
                       end
  end

  def self.prefetch(resources)
    nodes = instances
    resources.keys.each do |name|
      if provider = nodes.find { |node| node.name == name } # rubocop:disable all
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def flush
    if ! @property_hash.empty?
      update
    end
  end

  def self.run(command, check = false)
    result = ps_manager.execute(command)

    stdout      = result[:stdout]
    stderr      = result[:stderr]
    exit_code   = result[:exitcode]

    unless stderr.nil?
      stderr.each do |er|
        er.each { |e| Puppet.debug "STDERR: #{e.chop}" } unless er.empty?
      end
    end

    Puppet.debug "STDOUT: #{result[:stdout]}" unless result[:stdout].nil?
    Puppet.debug "ERRMSG: #{result[:errormessage]}" unless result[:errormessage].nil?

    return result
  end

  def self.ps_manager
    PuppetX::IIS::PowerShellManager.instance("#{command(:powershell)} #{PuppetX::IIS::PowerShellCommon.powershell_args.join(' ')}")
  end

  def self.ps_script_content(template, resource)
    @param_hash = resource
    template_path = File.expand_path('../templates', __FILE__)
    template_file = File.new(template_path + "/webadministration/#{template}.ps1.erb").read
    template      = ERB.new(template_file, nil, '-')
    template.result(binding)
  end
end
