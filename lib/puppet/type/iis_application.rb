require 'puppet/parameter/boolean'
require_relative '../../puppet_x/puppetlabs/iis/property/name'
require_relative '../../puppet_x/puppetlabs/iis/property/string'
require_relative '../../puppet_x/puppetlabs/iis/property/hash'
require_relative '../../puppet_x/puppetlabs/iis/property/path'
require_relative '../../puppet_x/puppetlabs/iis/property/authenticationinfo'

Puppet::Type.newtype(:iis_application) do
  desc <<-DOC
    @summary
      Allows creation of a new IIS Application and configuration of
          application parameters.

    The iis_application type uses an applicationname and a sitename to
    create an IIS Application. When specifying an application you must
    specify both. You can specify the sitename by putting it in the title
    as in \"$site_name\\$application_name\", or you can use the named
    parameters. If converting a virtual directory to an app, you can use
    the virtual_directory parameter to specify the site and omit the
    sitename parameter. To manage two applications of the same name within
    different websites on an IIS instance, you must ensure the resource
    title is unique. You can do this by entering both the sitename and
    applicationname in the title, or using a descriptive title for the
    resource and using the named parameters for sitename and
    applicationname
  DOC

  ensurable

  newparam(:applicationname, namevar: true) do
    desc "The name of the application. The virtual path of the application is
          '/<applicationname>'."
  end

  newproperty(:sitename, parent: PuppetX::PuppetLabs::IIS::Property::Name) do
    desc 'The name of the site for the application.'
  end

  newproperty(:physicalpath, parent: PuppetX::PuppetLabs::IIS::Property::Path) do
    desc 'The physical path to the application directory. This path must be
          fully qualified.'
    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'A non-empty physicalpath must be specified.'
      end
      raise("File paths must be fully qualified, not '#{value}'") unless value =~ /^.:(\/|\\)/ || value =~ /^\/\/[^\/]+\/[^\/]+/
    end
  end

  newproperty(:applicationpool, parent: PuppetX::PuppetLabs::IIS::Property::Name) do
    desc 'The name of the application pool for the application.'
    validate do |value|
      if value.nil? || value.empty?
        raise ArgumentError, 'A non-empty applicationpool name must be specified.'
      end
      super value
    end
  end

  newparam(:virtual_directory) do
    desc "The IIS Virtual Directory to convert to an application on create.
          Similar to iis_application, iis_virtual_directory uses composite
          namevars."

    munge do |value|
      value.start_with?('IIS:') ? value : File.join('IIS:/Sites', value)
    end
  end

  newproperty(:sslflags, array_matching: :all) do
    desc 'The SSL settings for the application. Valid options are an array of
          flags, with the following names: \'Ssl\', \'SslRequireCert\',
          \'SslNegotiateCert\', \'Ssl128\'.'
    newvalues(
      'Ssl',
      'SslRequireCert',
      'SslNegotiateCert',
      'Ssl128',
    )
  end

  newproperty(:authenticationinfo, parent: PuppetX::PuppetLabs::IIS::Property::AuthenticationInfo)

  newproperty(:enabledprotocols) do
    desc 'The comma-delimited list of enabled protocols for the application.
          Valid protocols are: \'http\', \'https\', \'net.pipe\', \'net.tcp\', \'net.msmq\', \'msmq.formatname\'.'
    validate do |value|
      return if value.nil?
      unless value.is_a?(String)
        raise("Invalid value '#{value}'. Should be a string")
      end

      raise("Invalid value ''. Valid values are http, https, net.pipe, net.tcp, net.msmq, msmq.formatname") if value.empty?

      protocols = value.split(',')
      protocols.each do |protocol|
        unless ['http', 'https', 'net.pipe', 'net.tcp', 'net.msmq', 'msmq.formatname'].include?(protocol)
          raise("Invalid protocol '#{protocol}'. Valid values are http, https, net.pipe, net.tcp, net.msmq, msmq.formatname")
        end
      end
    end
  end

  autorequire(:iis_application_pool) { self[:applicationpool] }
  autorequire(:iis_site) { self[:sitename] }
end
