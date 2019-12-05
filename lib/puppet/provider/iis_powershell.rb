require 'pathname'
require 'ruby-pwsh'

# This is the base class on which other providers are based.
class Puppet::Provider::IIS_PowerShell < Puppet::Provider # rubocop:disable all
  def initialize(value = {})
    super(value)
    @original_values = if value.is_a? Hash
                         value.clone
                       else
                         {}
                       end
  end

  # Match resources with existing providers
  def self.prefetch(resources)
    nodes = instances
    resources.keys.each do |name|
      if provider = nodes.find { |node| node.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  # update if exists
  def flush
    if exists?
      update
    end
  end

  # run command
  def self.run(command, _check = false)
    Puppet.debug("COMMAND: #{command}")

    if ps_major_version == 2
      # - PowerShell 2.0 does not support autoload of modules therefore we must explicitly add the WebAdministration module
      # - Must change the current location to the be the IIS: provider
      # - Add the ConvertTo-JSON command support
      command = "Import-Module WebAdministration -ErrorAction Stop\n" \
                "cd iis:\n" +
                ps_script_content('json_1.7', @resource) + "\n" \
                "$ConfirmPreference = 'high'" + "\n" +
                command
    end

    result = ps_manager.execute(command)
    stderr = result[:stderr]

    unless stderr.nil?
      stderr.each do |er|
        er.each { |e| Puppet.debug "STDERR: #{e.chop}" } unless er.empty?
      end
    end

    Puppet.debug "STDOUT: #{result[:stdout]}" unless result[:stdout].nil?
    Puppet.debug "ERRMSG: #{result[:errormessage]}" unless result[:errormessage].nil?

    result
  end

  # PowerShellManager - Responsible for managing PowerShell
  def self.ps_manager
    Pwsh::Manager.instance(command(:powershell), Pwsh::Manager.powershell_args)
  end

  # do_not_use_cached_value is typically only used for testing. In normal usage
  # the PowerShell version does not suddenly change during a Puppet run.
  def self.ps_major_version(do_not_use_cached_value = false)
    if @powershell_major_version.nil? || do_not_use_cached_value
      version = Pwsh::WindowsPowerShell.version
      @powershell_major_version = version.nil? ? nil : version.split('.').first.to_i
    end
    @powershell_major_version
  end

  # parse json result
  def self.parse_json_result(raw)
    return nil if raw.nil?
    # Unfortunately PowerShell tends to automatically insert CRLF characters mid-string (Console Width)
    # However as we're using JSON which does not use Line Endings for termination, we can safely strip them
    raw.delete!("\n")
    raw.delete!("\r")

    result = JSON.parse(raw)
    return nil if result.nil?

    # The JSON conversion for PowerShell 2.0 always creates a root HashTable with a single key of 'Objects'
    # whereas under PowerShell 3.0+ this is not the case.  Detect the PowerShell 2.0 style and render it back
    # into a PowerShell 3.0+ format.
    if result.is_a?(Hash) && result.keys[0] == 'Objects'
      return nil if result['Objects'].nil?

      # Due to Convert-XML in PowerShell 2.0 converting elements with empty elements (<something />) into nulls,
      # need to be careful how things are processed e.g.
      # - An empty array comes in as nil
      # - A blank string comes in as nil
      # Only the provider will be able to determine what a nil value really means

      # If only a single object is returned then the result is Hash with a single 'Object' key
      # if multiple objects are returned then the result is an array of Hashes
      if result['Objects'].is_a?(Hash) && result['Objects'].keys[0] == 'Object'
        return [result['Objects']['Object']]
      elsif result['Objects'].is_a?(Array)
        return result['Objects']
      else
        raise 'Unable to determine the JSON encoding from PowerShell 2.0'
      end
    end

    # Always return an Array type
    result.is_a?(Array) ? result : [result]
  end

  # powershell script content
  def self.ps_script_content(template, resource)
    @param_hash = resource
    template_path = File.expand_path('../templates', __FILE__)
    template_file = File.new(template_path + "/webadministration/#{template}.ps1.erb").read
    template      = ERB.new(template_file, nil, '-')
    template.result(binding)
  end
end
