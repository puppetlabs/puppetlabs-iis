Puppet::Type.newtype(:iis_webconfigurationproperty) do
  @doc = "Manage IIS Web Configuration Properties."
  newparam(:name, :namevar => :true) do
    desc "The name of the configuration property to change."
  end
  newproperty(:value) do
    desc "The value of the configuration setting to change."
  end
  newparam(:filter, :namevar => :true) do
    desc "Specifies the XPath query that returns a configuration element."
  end
  newparam(:location, :namevar => :true) do
    desc "Configuration location in which the property is configured."
    defaultto ""
  end
  newparam(:pspath, :namevar => :true) do
    desc "An IIS configuration path to the location in which the property is configured."
    defaultto "MACHINE/WEBROOT/APPHOST"
  end
  # We have more than one namevar, so we need title_patterns.
  # 
  # The following resources will be seen as unique by puppet: 
  # 
  #     # Uniqueness Key: ['404', '', 'MACHINE/WEBROOT/APPHOST'] 
  #     iis_httperror{'404': }
  # 
  #     # Uniqueness Key: ['404', '', 'MACHINE/WEBROOT/APPHOST/Default Web Site'] 
  #     iis_httperror{'404': 
  #       pspath => 'MACHINE/WEBROOT/APPHOST/Default Web Site',
  #     } 
  # 
  # Declarations that implicitly use a default pspath or location will clash
  # with those that explicitly use the default.
  def self.title_patterns
    [
      [
        /(.*)\/([^\/]*)/m,
        [ [:filter], [:name] ]
      ],
      [
        /([^\/]*)/m,
        [ [:name] ]
      ]
    ] 
  end
end