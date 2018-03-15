require 'puppet/parameter/boolean'
require_relative '../../puppet_x/puppetlabs/iis/property/name'
require_relative '../../puppet_x/puppetlabs/iis/property/string'
require_relative '../../puppet_x/puppetlabs/iis/property/hash'

Puppet::Type.newtype(:iis_application) do
  @doc = "Allows creation of a new IIS Application and configuration of
          application parameters.

          The iis_application type uses a composite namevar for applicationname
          and sitename to uniquely identify a declaration. To use this
          successfully, put both the sitename and the applicationname in the
          title. Puppet will build the catalog using the composite of the two
          values, while still using the correct value for the applicationname
          when creating the IIS application. It requires a \ in between the
          sitename and applicationname, for example,
          iis_application { '\#{@site_name}\\\#{@app_name}'."

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

  newparam(:applicationname, :namevar => true) do
    desc "The name of the application. The virtual path of the application is
          '/<applicationname>'."
    validate do |value|
      if value =~ /^\/|^\\/
        raise ArgumentError, "cannot begin applicationname property with a '\\' or a '/' character"
      end
    end
  end

  newproperty(:sitename, :namevar => true, :parent => PuppetX::PuppetLabs::IIS::Property::Name) do
    desc 'The name of the site for the application.'
  end

  newproperty(:physicalpath) do
    desc 'The physical path to the application directory. This path must be
          fully qualified.'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty physicalpath must be specified."
      end
      fail("File paths must be fully qualified, not '#{value}'") unless value =~ /^.:(\/|\\)/ or value =~ /^\/\/[^\/]+\/[^\/]+/
    end
  end

  newproperty(:applicationpool, :parent => PuppetX::PuppetLabs::IIS::Property::Name) do
    desc 'The name of the application pool for the application.'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty applicationpool name must be specified."
      end
      super value
    end
  end

  newparam(:virtual_directory) do
    desc "The IIS Virtual Directory to convert to an application on create.
          Similar to iis_application, iis_virtual_directory uses composite
          namevars."
  end

  newproperty(:sslflags, :array_matching => :all) do
    desc 'The SSL settings for the application. Valid options are an array of
          flags, with the following names: \'Ssl\', \'SslRequireCert\',
          \'SslNegotiateCert\', \'Ssl128\'.'
    newvalues(
      "Ssl",
      "SslRequireCert",
      "SslNegotiateCert",
      "Ssl128",
    )
  end

  newproperty(:authenticationinfo, :parent => PuppetX::PuppetLabs::IIS::Property::Hash) do
    desc 'Enable and disable IIS authentication schemas.'
    def insync?(is)
      should.select do |k,v|
        is[k] != v
      end.empty?
    end
  end

  newproperty(:enabledprotocols) do
    desc 'The comma-delimited list of enabled protocols for the application.
          Valid protocols are: \'http\', \'https\', \'net.pipe\'.'
    validate do |value|
      return if value.nil?
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end

      fail("Invalid value ''. Valid values are http, https, net.pipe") if value.empty?

      protocols = value.split(',')
      protocols.each do |protocol|
        unless ['http', 'https', 'net.pipe'].include?(protocol)
          fail("Invalid protocol '#{protocol}'. Valid values are http, https, net.pipe")
        end
      end
    end
  end

  autorequire(:iis_application_pool) { self[:applicationpool] }
  autorequire(:iis_site) { self[:sitename] }

  validate do
    fail("sitename is a required parameter") if (provider && ! provider.sitename) or ! self[:sitename]
  end
end
