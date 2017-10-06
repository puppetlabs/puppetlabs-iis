Puppet::Type.newtype(:iis_isapifilter) do
  @doc = "Manage IIS ISAPI filters to process client request data or server response data."
  ensurable
  newparam(:name, :namevar => :true) do
    desc "Specifies the unique name of the ISAPI filter."
  end
  newproperty(:enabled, :boolean => true) do
    desc "Specifies whether the installed filter is enabled (true) or disabled (false)."
    newvalues(:true, :false)
    defaultto :true
    munge do |value|
      case value
      when true, "true", :true
        :true
      when false, "false", :false
        :false
      else
        raise ArgumentError,
          "Only boolean values allowed"
      end
    end
  end
  newproperty(:enablecache, :boolean => true) do
    desc "Specifies whether HTTP.sys caching is enabled (true) or disabled (false) for filtered server responses."
    newvalues(:true, :false)
    defaultto :false
    munge do |value|
      case value
      when true, "true", :true
        :true
      when false, "false", :false
        :false
      else
        raise ArgumentError,
          "Only boolean values allowed"
      end
    end
  end
  newproperty(:path) do
    desc "Specifies the full physical path of the ISAPI filter .dll file."
  end
  newproperty(:precondition) do
    desc "Specifies conditions under which the ISAPI filter will run."
  end
  newparam(:location, :namevar => :true) do
    desc "Configuration location in which the handler is configured."
    defaultto ""
  end
  newparam(:pspath, :namevar => :true) do
    desc "An IIS configuration path to the location in which the module is configured."
    defaultto "MACHINE/WEBROOT/APPHOST"
  end
  # We have more than one namevar, so we need title_patterns.
  # 
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