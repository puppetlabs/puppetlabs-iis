require 'puppet/parameter/boolean'
require_relative '../../puppet_x/puppetlabs/iis/property/string'
require_relative '../../puppet_x/puppetlabs/iis/property/hash'
require_relative '../../puppet_x/puppetlabs/iis/property/name'

Puppet::Type.newtype(:iis_application) do
  @doc = "Manage an IIS applications."

  ensurable

  def self.title_patterns
    [
      [
        /^([^\\]+)\\([^\\]+)$/,
        [
          [:sitename],
          [:applicationname],
        ]
      ],
      [
        /^([^\\]+)$/,
        [
          [:applicationname],
        ]
      ]
    ]
  end

  # TODO: Implement virtual path character validation, since applicationname is used in the virtual path.
  newparam(:applicationname, :namevar => true) do
    desc "The name of the Application. The virtual path of an application is /<applicationname>"
  end

  newproperty(:sitename, :namevar => true, :parent => PuppetX::PuppetLabs::IIS::Property::Name) do
    desc 'The name of the site for this IIS Web Application'
  end

  newproperty(:physicalpath) do
    desc 'The physical path to the IIS web application folder'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty physicalpath must be specified."
      end
      fail("File paths must be fully qualified, not '#{value}'") unless value =~ /^.:(\/|\\)/ or value =~ /^\/\/[^\/]+\/[^\/]+/
    end
  end

  newproperty(:applicationpool, :parent => PuppetX::PuppetLabs::IIS::Property::Name) do
    desc 'The name of an ApplicationPool for this IIS Web Application'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty applicationpool must be specified."
      end
      super value
      fail("The applicationpool must be less than 64 characters") unless value.length < 64
    end
  end

  newparam(:virtual_directory) do
    desc "The Web Virtual Directory to convert to a Web Application on create."
  end

  newproperty(:sslflags, :array_matching => :all) do
    desc 'The ssl settings for the application.'
    newvalues(
      "Ssl",
      "SslRequireCert",
      "SslNegotiateCert",
      "Ssl128",
    )
  end

  newproperty(:authenticationinfo, :parent => PuppetX::PuppetLabs::IIS::Property::Hash) do
    desc 'Enable and disable authentication schemas'
    def insync?(is)
      should.select do |k,v|
        is[k] != v
      end.empty?
    end
  end

  autorequire(:iis_application_pool) { self[:applicationpool] }
  autorequire(:iis_site) { self[:sitename] }

  validate do
    fail("sitename is a required parameter") if (provider && ! provider.sitename) or ! self[:sitename]
  end
end
