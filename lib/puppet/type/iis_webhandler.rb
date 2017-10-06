Puppet::Type.newtype(:iis_webhandler) do
  @doc = "Manage IIS request handlers."
  ensurable
  newparam(:name, :namevar => :true) do
    desc "The name of the request handler."
  end
  newproperty(:path) do
    desc "The physical path to the handler (native modules only)."
  end
  newproperty(:verb) do
    desc "HTTP verbs for which the handler is executed."
  end
  newproperty(:type) do
    desc "Managed Type of the handler (managed modules only)."
  end
  newproperty(:modules) do
    desc "Modules needed for the handler (native handlers only)."
  end
  newproperty(:scriptprocessor) do
    desc "Script processor to execute for the handler (native handlers only)."
  end
  newproperty(:precondition) do
    desc "Preconditions for the new handler."
  end
  newproperty(:resourcetype) do
    desc "Resource type required for the handler."
  end
  newproperty(:requireaccess) do
    desc "The user rights that are required for the new handler: Read, Write, Execute, or Script."
    newvalues(:read, :write, :execute, :script)
    defaultto :script
    munge do |value|
      value.to_s
    end
    def insync?(is)
      is.downcase == should.downcase
    end
  end
  newparam(:location, :namevar => :true) do
    desc "Configuration location in which the handler is configured."
    defaultto ""
  end
  newparam(:pspath, :namevar => :true) do
    desc "An IIS configuration path to the location in which the module is configured."
    defaultto "MACHINE/WEBROOT/APPHOST"
  end
  # The following resources will be seen as unique by puppet: 
  # 
  #     # Uniqueness Key: ['svc-ISAPI-4.0_32bit', '', 'MACHINE/WEBROOT/APPHOST'] 
  #     iis_webhandler{'svc-ISAPI-4.0_32bit': }
  # 
  #     # Uniqueness Key: ['svc-ISAPI-4.0_32bit', '', 'MACHINE/WEBROOT/APPHOST/Default Web Site'] 
  #     iis_webhandler{'svc-ISAPI-4.0_32bit': 
  #       pspath => 'MACHINE/WEBROOT/APPHOST/Default Web Site',
  #     } 
  # 
  # Declarations that implicitly use a default pspath or location will clash
  # with those that explicitly use the default.
  def self.title_patterns
    [
      [
        /(.*)/m,
        [ [:name] ]
      ]
    ] 
  end
end