Puppet::Type.newtype(:iis_httperror) do
  @doc = "Manage IIS HTTP error responses."
  ensurable
  newparam(:name, :namevar => :true) do
    desc "The number of the HTTP status code for which you want to create a custom error message, optionally including the HTTP substatus code for which you want to create a custom error message."
    # 400-999 or 400-999.0-999
    newvalues(/^([4-9][0-9]{2}|[4-9][0-9]{2}\.[0-9]{1,3})$/)
  end
  newproperty(:prefixlanguagefilepath) do
    desc "Specifies the initial path segment when generating the path for a custom error. This segment appears before the language-specific portion of the custom error path. For example, in the path C:\\Inetpub\\Custerr\\en-us\\404.htm, C:\\Inetpub\\Custerr is the prefixLanguageFilePath."
  end
  newproperty(:path) do
    desc "Specifies the file path or URL that is served in response to the HTTP error specified by the statusCode and subStatusCode attributes. If you choose the File response mode, you specify the path of the custom error page. If you choose the ExecuteURL response mode, the path has to be a server relative URL (for example, /404.htm). If you choose the Redirect response mode, you have to enter an absolute URL (for example, www.contoso.com/404.htm)."
  end
  newproperty(:responsemode) do
    desc "Specifies how custom error content is returned. The responseMode attribute can be one of the following possible values: File, ExecuteURL or Redirect. The default is File."
    newvalues(:file, :executeurl, :redirect)
    defaultto :file
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
        /(.*)/m,
        [ [:name] ]
      ]
    ] 
  end
end