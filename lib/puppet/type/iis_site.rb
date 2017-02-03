require 'puppet/parameter/boolean'

Puppet::Type.newtype(:iis_site) do
  @doc = "Create a new IIS website."

  newproperty(:ensure) do
    desc "Specifies whether a site should be present or absent. If present is
      specified, the site will be created but left in the default stopped state.
      If started is specified, then the site will be created as well as started.
      If stopped is specified, then the site will be created and kept stopped."

    newvalue(:stopped) do
      provider.stop
    end

    newvalue(:started) do
      provider.start
    end

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    aliasvalue(:false, :stopped)
    aliasvalue(:true, :started)
  end

  newparam(:name, :namevar => true) do
    desc "The Name of the IIS site. Used for uniqueness. Will set
      the target to this value if target is unset."

    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty name must be specified."
      end
      fail("#{name} is not a valid web site name") unless value =~ /^[a-zA-Z0-9\-\_'\s]+$/
    end
  end

  newproperty(:physicalpath) do
    desc 'The physical path to the IIS web site folder'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty physicalpath must be specified."
      end
      fail("File paths must be fully qualified, not '#{value}'") unless value =~ /^.:(\/|\\)/ or value =~ /^\/\/[^\/]+\/[^\/]+/
    end
  end

  newproperty(:applicationpool) do
    desc 'The name of an ApplicationPool for this IIS Web Site'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty applicationpool name must be specified."
      end
      fail("#{name} is not a valid applicationpool name") unless value =~ /^[a-zA-Z0-9\-\_'\s]+$/
    end
  end

  newproperty(:enabledprotocols) do
    desc 'The protocols enabled for this site. If https is specified, http is implied.
      If no value is provided, then this setting is disabled'
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['http','https'].include?(value)
        fail("Invalid value '#{value}'. Valid values are http, https")
      end
    end
  end

  newproperty(:serviceautostart, :boolean => true) do
    desc 'Enables autostart on the specified website'
    newvalue(:true)
    newvalue(:false)

    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:serviceautostartprovidername) do
    desc 'Specifies the provider used for service auto start. Used with :serviceautostartprovidertype.
    The <serviceAutoStartProviders> element specifies a collection of managed assemblies that
    Windows Process Activation Service (WAS) will load automatically when the startMode attribute of an
    application pool is set to AlwaysRunning. This collection allows developers to specify assemblies that perform
    initialization tasks before any HTTP requests are serviced.
    
    example:
    serviceautostartprovidername => "MyAutostartProvider"
    serviceautostartprovidertype => "MyAutostartProvider, MyAutostartProvider, version=1.0.0.0, Culture=neutral, PublicKeyToken=426f62526f636b73"
    '
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty serviceautostartprovidername name must be specified."
      end
      fail("#{name} is not a valid serviceautostartprovidername name") unless value =~ /^[a-zA-Z0-9\-\_'\s]+$/
    end
    # serviceautostartprovidertype and serviceautostartprovidername work together
  end

  newproperty(:serviceautostartprovidertype) do
    # serviceautostartprovidertype and serviceautostartprovidername work together
    desc 'Specifies the application type for the provider used for service auto start. Used with :serviceautostartprovider
    example:
    serviceautostartprovidername => "MyAutostartProvider"
    serviceautostartprovidertype => "MyAutostartProvider, MyAutostartProvider, version=1.0.0.0, Culture=neutral, PublicKeyToken=426f62526f636b73"
    '
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty serviceautostartprovidertype name must be specified."
      end
      # fail("#{name} is not a valid serviceautostartprovidertype name") unless value =~ /^[a-zA-Z0-9\-\_'\s]+$/
    end
    
  end

  newproperty(:preloadenabled, :boolean => true) do
    desc 'Enables loading website automatically without a client request first'
    newvalue(:true)
    newvalue(:false)

    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:defaultpage, :array_matching => :all) do
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty defaultpage must be specified."
      end
      unless value.kind_of?(Array) || value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string or an array of strings")
      end
    end
  end

  newproperty(:logformat) do
    desc 'Specifies the format for the log file. When set to WSC,
      it can be used in conjunction with :logflags'
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['W3C','IIS','NCSA'].include?(value)
        fail("Invalid value '#{value}'. Valid values are W3C, IIS, NCSA")
      end
    end
  end

  newproperty(:logpath) do
    desc 'Specifies the physical path to place the log file'
    validate do |value|
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty logpath must be specified."
      end
      fail("File paths must be fully qualified, not '#{value}'") unless value =~ /^.:(\/|\\)/ or value =~ /^\/\/[^\/]+\/[^\/]+/
    end
  end

  newproperty(:logperiod) do
    desc 'Specifies how often the log file should rollover'
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Hourly','Daily','Weekly','Monthly','MaxSize'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Hourly, Daily, Weekly, Monthly, MaxSize")
      end
    end
  end

  newproperty(:logtruncatesize) do
    desc 'Specifies how large the log file should be before truncating it.
      The value must be in bytes. The value can be any size
      between \'1048576 (1MB)\' and \'4294967295 (4GB)\'.
      '
    validate do |value|
      unless value.kind_of?(Integer)
        fail("Invalid value '#{value}'. Should be a number")
      end
      if value < 1048576 or value > 4294967295
        fail("Invalid value '#{value}'. Cannot be less than 1048576 or greater than 4294967295")
      end
    end
  end

  newproperty(:loglocaltimerollover, :boolean => true) do
    desc 'Use the system\'s local time to determine for the log file name as
       as well as when the log file is rolled over'
    newvalue(:true)
    newvalue(:false)

    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:logflags, :array_matching => :all) do
    desc 'Specifies what W3C fields are logged in the IIS log file. This is only
      valid when :logformat is set to W3C. '
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid logflags value '#{value}'. Should be a string")
      end
      unless [
        'Date','Time','ClientIP','UserName','SiteName','ComputerName','ServerIP',
        'Method','UriStem','UriQuery','HttpStatus','Win32Status','BytesSent',
        'BytesRecv','TimeTaken','ServerPort','UserAgent','Cookie','Referer',
        'ProtocolVersion','Host','HttpSubStatus'
      ].include?(value)
        fail("Invalid value '#{value}'. Valid values are Date, Time, ClientIP,
             UserName, SiteName, ComputerName, ServerIP,
             Method, UriStem, UriQuery, HttpStatus, Win32Status, BytesSent,
             BytesRecv, TimeTaken, ServerPort, UserAgent, Cookie, Referer,
             ProtocolVersion, Host, HttpSubStatus")
      end
    end

    def insync?(is)
      is.sort == should.sort
    end
  end

  validate do
    # TODO: These need validation
    # logperiod and logtruncatesize
    # logtruncatesize needs int range validation
    # logflags need to support 4 values and no value
    # enabledprotocols need to support 2 values and no value

    # TODO: need check if logperiod is not MaxSize if logtruncatesize is set. if not
    if self[:logperiod] && self[:logtruncatesize]
      fail("Cannot specify logperiod and logtruncatesize at the same time")
    end

    # can only use logflags if logformat is W3C
    if self[:logflags]
      unless ['W3C','w3c'].include?(self[:logformat])
        fail("Cannot specify logflags when logformat is not W3C")
      end
    end
    
    if self[:serviceautostartprovidername]
      fail("Must specify serviceautostartprovidertype as well as serviceautostartprovidername") unless self[:serviceautostartprovidertype]
    end
    
    if self[:serviceautostartprovidertype]
      fail("Must specify serviceautostartprovidername as well as serviceautostartprovidertype") unless self[:serviceautostartprovidername]
    end

    provider.validate if provider.respond_to?(:validate)
  end

  def munge_boolean(value)
    case value
      when true, "true", :true
        :true
      when false, "false", :false
        :false
      else
        fail("munge_boolean only takes booleans")
    end
  end
end
