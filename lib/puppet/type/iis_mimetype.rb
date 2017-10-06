Puppet::Type.newtype(:iis_mimetype) do
  @doc = "Manage IIS unique MIME types in the collection of static content types."
  ensurable
  newparam(:fileextension, :namevar => :true) do
    desc "The unique file name extension for a MIME type."
  end
  newproperty(:mimetype) do
    desc "The type of file and the application that uses this kind of file name extension."
  end
  newparam(:location, :namevar => :true) do
    desc "Configuration location in which the handler is configured."
    defaultto ""
  end
  newparam(:pspath, :namevar => :true) do
    desc "An IIS configuration path to the location in which the module is configured."
    defaultto "MACHINE/WEBROOT/APPHOST"
  end
  newparam(:name) do
    desc "Only used internally within the provider. Workaround for a composite namevar without name parameter."
    validate do |value|
      raise ArgumentError, "The parameter 'name' is only used internally within the provider as a workaround for a composite namevar without name parameter."
    end
  end
  # We have more than one namevar, so we need title_patterns.
  # 
  # The following resources will be seen as unique by puppet: 
  # 
  #     # Uniqueness Key: ['.zip', '', '', 'MACHINE/WEBROOT/APPHOST'] 
  #     iis_mimetype{'.zip': }
  # 
  #     # Uniqueness Key: ['.zip', '', '', 'MACHINE/WEBROOT/APPHOST/Default Web Site'] 
  #     iis_mimetype{'.zip': 
  #       pspath => 'MACHINE/WEBROOT/APPHOST/Default Web Site',
  #     } 
  # 
  # Declarations that implicitly use a default pspath or location will clash
  # with those that explicitly use the default.
  def self.title_patterns
    [
      [
        /(.*)/m,
        [ [:fileextension] ]
      ]
    ] 
  end

end