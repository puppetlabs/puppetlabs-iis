# frozen_string_literal: true

require 'puppet/parameter/boolean'
require_relative '../../puppet_x/puppetlabs/iis/property/name'
require_relative '../../puppet_x/puppetlabs/iis/property/hash'
require_relative '../../puppet_x/puppetlabs/iis/property/path'
require_relative '../../puppet_x/puppetlabs/iis/property/authenticationinfo'

Puppet::Type.newtype(:iis_site) do
  @doc = "Allows creation of a new IIS Web Site and configuration of site
          parameters."

  newproperty(:ensure) do
    desc "Specifies whether a site should be present or absent. If present is
          specified, the site will be created but left in the default stopped
          state. If started is specified, then the site will be created as well
          as started. If stopped is specified, then the site will be created and
          kept stopped."

    newvalue(:stopped) do
      provider.stop
    end

    newvalue(:started) do
      provider.start
    end

    newvalue(:present) do
      provider.create unless provider.exists?
    end

    newvalue(:absent) do
      provider.destroy
    end

    def insync?(is)
      is.to_s == should.to_s ||
        (is.to_s == 'started' && should.to_s == 'present') ||
        (is.to_s == 'stopped' && should.to_s == 'present')
    end

    aliasvalue(:false, :stopped)
    aliasvalue(:true, :started)
  end

  newparam(:name, namevar: true, parent: PuppetX::PuppetLabs::IIS::Property::Name) do
    desc "The Name of the IIS site. Used for uniqueness. Will set
      the target to this value if target is unset."

    validate do |value|
      raise ArgumentError, 'A non-empty name must be specified.' if value.nil? || value.empty?

      super value
    end
  end

  newproperty(:physicalpath, parent: PuppetX::PuppetLabs::IIS::Property::Path) do
    desc 'The physical path to the site directory. This path must be fully qualified.'
    munge do |value|
      v = value.chomp('/') if value.match?(%r{^.:(/|\\)})
      v = value.chomp('\\') if value.match?(%r{^(/|\\)(/|\\)[^(/|\\)]+(/|\\)[^(/|\\)]+})

      raise ArgumentError, 'A non-empty physicalpath must be specified.' if v.nil? || v.empty?
      raise("File paths must be fully qualified, not '#{v}'") unless v =~ %r{^.:(/|\\)} || v =~ %r{^(/|\\)(/|\\)[^(/|\\)]+(/|\\)[^(/|\\)]+}

      v
    end
  end

  newproperty(:applicationpool, parent: PuppetX::PuppetLabs::IIS::Property::Name) do
    desc 'The name of an ApplicationPool for this IIS Web Site'
    validate do |value|
      raise ArgumentError, 'A non-empty applicationpool name must be specified.' if value.nil? || value.empty?

      super value
    end
  end

  newproperty(:enabledprotocols) do
    desc "The protocols enabled for the site. If 'https' is specified, 'http' is
          implied. If no value is provided, then this setting is disabled. Can
          be a comma delimited list of protocols. Valid protocols are: 'http',
          'https', 'net.pipe', 'net.tcp', 'net.msmq', 'msmq.formatname'."
    validate do |value|
      raise("Invalid value '#{value}'. Should be a string") unless value.is_a?(String)

      raise("Invalid value ''. Valid values are http, https, net.pipe, net.tcp, net.msmq, msmq.formatname") if value.empty?

      allowed_protocols = ['http', 'https', 'net.pipe', 'net.tcp', 'net.msmq', 'msmq.formatname'].freeze
      protocols = value.split(',')
      protocols.each do |protocol|
        raise("Invalid protocol '#{protocol}'. Valid values are http, https, net.pipe, net.tcp, net.msmq, msmq.formatname") unless allowed_protocols.include?(protocol)
      end
    end
  end

  newproperty(:bindings, array_matching: :all) do
    desc 'The protocol, address, port, and ssl certificate bindings for a web
          site.

          For web (http/https) protocols, the bindinginformation value should
          be in the form of the IPv4/IPv6 address or wildcard *, then the port,
          then the optional hostname separated by colons:
          `(ip|\*):[1-65535]:(hostname)?`

          A protocol value of "http" indicates a binding that uses the HTTP
          protocol. A value of "https" indicates a binding that uses HTTP over
          SSL.

          The sslflags parameter accepts integer values from 0 to 3 inclusive.
          - A value of "0" specifies that the secure connection be made using an
            IP/Port combination. Only one certificate can be bound to a
            combination of IP address and the port.
          - A value of "1" specifies that the secure connection be made using
            the port number and the host name obtained by using Server Name
            Indication (SNI).
          - A value of "2" specifies that the secure connection be made using
            the centralized SSL certificate store without requiring a Server
            Name Indicator.
          - A value of "3" specifies that the secure connection be made using
            the centralized SSL certificate store while requiring Server Name
            Indicator'

    validate do |value|
      raise('All bindings must be a hash') unless value.is_a?(Hash)
      raise('All bindings must specify protocol and bindinginformation values') unless (['protocol', 'bindinginformation'] - value.keys).empty?
      unless ['http', 'https', 'net.pipe', 'net.tcp', 'net.msmq', 'msmq.formatname'].include?(value['protocol'])
        raise("Invalid value '#{value}'. Valid values are http, https, net.pipe, net.tcp, net.msmq, msmq.formatname")
      end

      if ['http', 'https'].include?(value['protocol'])
        raise("bindinginformation for http and https protocols must be of the format '(ip|*):1-65535:hostname'") unless %r{^.+:\d+:.*}.match?(value['bindinginformation'])
      elsif ['net.pipe'].include?(value['protocol'])
        raise("bindinginformation for net.pipe protocol must be of the format 'hostname'") unless %r{^[^:]+$}.match?(value['bindinginformation'])
      elsif ['net.tcp'].include?(value['protocol'])
        raise("bindinginformation for net.tcp protocol must be of the format '1-65535:hostname'") unless %r{^\d+:.*}.match?(value['bindinginformation'])
      elsif ['net.msmq'].include?(value['protocol'])
        raise("bindinginformation for net.msmq protocol must be of the format 'hostname'") unless %r{^[^:]+$}.match?(value['bindinginformation'])
      elsif ['msmq.formatname'].include?(value['protocol'])
        raise("bindinginformation for msmq.formatname protocol must be of the format 'hostname'") unless %r{^[^:]+$}.match?(value['bindinginformation'])
      end

      if ['http', 'net.pipe', 'net.tcp', 'net.msmq', 'msmq.formatname'].include?(value['protocol']) && (value['sslflags'] || value['certificatehash'] || value['certificatestorename'])
        raise("#{value['bindinginformation']}: sslflags, certificatehash, and certificatestorename are only valid when the protocol is https")
      end

      if value['protocol'] == 'https'
        raise("#{value['bindinginformation']}: sslflags must be an integer 0, 1, 2, or 3") unless [0, 1, 2, 3].include?(value['sslflags'])
        raise("#{value['bindinginformation']}: certificatehash and certificatestorename are required for https bindings") if !value['certificatehash'] || !value['certificatestorename']
      end
    end
    munge do |value|
      value['certificatehash'] = value['certificatehash'].upcase if !value.nil? && value['certificatehash']
      value['certificatestorename'] = value['certificatestorename'].upcase if !value.nil? && value['certificatestorename']
      value
    end

    def insync?(is)
      (is || []).to_set == (should || []).to_set
    end
  end

  newproperty(:serviceautostart, boolean: true) do
    desc 'Enables autostart on the specified website'
    newvalue(:true)
    newvalue(:false)

    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:serviceautostartprovidername) do
    desc 'Specifies the provider used for service auto start. Used with
          :serviceautostartprovidertype. The <serviceAutoStartProviders>
          element specifies a collection of managed assemblies that Windows
          Process Activation Service (WAS) will load automatically when the
          startMode attribute of an application pool is set to AlwaysRunning.
          This collection allows developers to specify assemblies that perform
          initialization tasks before any HTTP requests are serviced.

          example:
          serviceautostartprovidername => "MyAutostartProvider"
          serviceautostartprovidertype => "MyAutostartProvider, MyAutostartProvider, version=1.0.0.0, Culture=neutral, PublicKeyToken=426f62526f636b73"'
    validate do |value|
      raise ArgumentError, 'A non-empty serviceautostartprovidername name must be specified.' if value.nil? || value.empty?
      raise("#{name} is not a valid serviceautostartprovidername name") unless %r{^[a-zA-Z0-9\-_'\s]+$}.match?(value)
    end
    # serviceautostartprovidertype and serviceautostartprovidername work together
  end

  newproperty(:serviceautostartprovidertype) do
    desc 'Specifies the application type for the provider used for service auto
          start. Used with :serviceautostartprovider

          example:
          serviceautostartprovidername => "MyAutostartProvider"
          serviceautostartprovidertype => "MyAutostartProvider, MyAutostartProvider, version=1.0.0.0, Culture=neutral, PublicKeyToken=426f62526f636b73"'
    validate do |value|
      raise ArgumentError, 'A non-empty serviceautostartprovidertype name must be specified.' if value.nil? || value.empty?
    end
  end

  newproperty(:preloadenabled, boolean: true) do
    desc 'Enables loading website automatically without a client request first'
    newvalue(:true)
    newvalue(:false)

    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:defaultpage, array_matching: :all) do
    desc 'Specifies the default page of the site.'
    validate do |value|
      raise ArgumentError, 'A non-empty defaultpage must be specified.' if value.nil? || value.empty?
      raise("Invalid value '#{value}'. Should be a string or an array of strings") unless value.is_a?(Array) || value.is_a?(String)
    end
  end

  newproperty(:logformat) do
    desc "Specifies the format for the log file. When set to 'W3C', used with
          `logflags`"
    validate do |value|
      raise("Invalid value '#{value}'. Should be a string") unless value.is_a?(String)
      raise("Invalid value '#{value}'. Valid values are W3C, IIS, NCSA") unless ['W3C', 'IIS', 'NCSA'].include?(value)
    end
  end

  newproperty(:logpath, parent: PuppetX::PuppetLabs::IIS::Property::Path) do
    desc 'Specifies the physical path to place the log file'
    validate do |value|
      raise ArgumentError, 'A non-empty logpath must be specified.' if value.nil? || value.empty?
      raise("File paths must be fully qualified, not '#{value}'") unless value =~ %r{^.:(/|\\)} || value =~ %r{^//[^/]+/[^/]+}
    end
  end

  newproperty(:logperiod) do
    desc 'Specifies how often the log file should rollover'
    validate do |value|
      raise("Invalid value '#{value}'. Should be a string") unless value.is_a?(String)
      raise("Invalid value '#{value}'. Valid values are Hourly, Daily, Weekly, Monthly, MaxSize") unless ['Hourly', 'Daily', 'Weekly', 'Monthly', 'MaxSize'].include?(value)
    end
  end

  newproperty(:logtruncatesize) do
    desc 'Specifies how large the log file should be before truncating it. The
          value must be in bytes. The value can be any size between
          \'1048576 (1MB)\' and \'4294967295 (4GB)\'.'
    validate do |value|
      raise("Invalid value '#{value}'. Should be a number") unless value.is_a?(Integer)
      raise("Invalid value '#{value}'. Cannot be less than 1048576 or greater than 4294967295") if value < 1_048_576 || value > 4_294_967_295
    end
  end

  newproperty(:loglocaltimerollover, boolean: true) do
    desc 'Use the system\'s local time to determine for the log file name as
          well as when the log file is rolled over'
    newvalue(:true)
    newvalue(:false)

    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:logflags, array_matching: :all) do
    desc "Specifies what W3C fields are logged in the log file. This is only
          valid when `logformat` is set to 'W3C'."
    validate do |value|
      raise("Invalid logflags value '#{value}'. Should be a string") unless value.is_a?(String)

      unless [
        'Date', 'Time', 'ClientIP', 'UserName', 'SiteName', 'ComputerName', 'ServerIP',
        'Method', 'UriStem', 'UriQuery', 'HttpStatus', 'Win32Status', 'BytesSent',
        'BytesRecv', 'TimeTaken', 'ServerPort', 'UserAgent', 'Cookie', 'Referer',
        'ProtocolVersion', 'Host', 'HttpSubStatus'
      ].include?(value)
        raise("Invalid value '#{value}'. Valid values are Date, Time, ClientIP,
             UserName, SiteName, ComputerName, ServerIP,
             Method, UriStem, UriQuery, HttpStatus, Win32Status, BytesSent,
             BytesRecv, TimeTaken, ServerPort, UserAgent, Cookie, Referer,
             ProtocolVersion, Host, HttpSubStatus")
      end
    end
  end

  def insync?(is)
    is.sort == should.sort
  end

  newproperty(:limits) do
    desc 'Configure limits for an IIS Site'
    valid_limits = ['connectiontimeout', 'maxbandwidth', 'maxconnections']
    validate do |value|
      raise "#{name} should be a Hash" unless value.is_a? Hash

      value.each do |key, limit|
        raise("Invalid iis site limit key '#{key}'. Should be one of: #{valid_limits}") unless valid_limits.include? key
        raise("Invalid value '#{limit}' for #{key}. Must be an integer") unless limit.is_a? Integer
        raise("Invalid value '#{limit} for #{key}'. Cannot be less than 1 or greater than 4294967295") if key != 'connectiontimeout' && (limit < 1 || limit > 4_294_967_295)
      end
    end
    def insync?(is)
      should.reject { |k, v|
        is[k] == v
      }.empty?
    end
  end

  newproperty(:authenticationinfo, parent: PuppetX::PuppetLabs::IIS::Property::AuthenticationInfo)

  autorequire(:iis_application_pool) { self[:applicationpool] }

  validate do
    # TODO: These need validation
    # logperiod and logtruncatesize
    # logtruncatesize needs int range validation
    # logflags need to support 4 values and no value
    # enabledprotocols need to support 2 values and no value

    # TODO: need check if logperiod is not MaxSize if logtruncatesize is set. if not
    raise('Cannot specify logperiod and logtruncatesize at the same time') if self[:logperiod] && self[:logtruncatesize]

    # can only use logflags if logformat is W3C
    raise('Cannot specify logflags when logformat is not W3C') if self[:logflags] && !['W3C', 'w3c'].include?(self[:logformat])

    raise('Must specify serviceautostartprovidertype as well as serviceautostartprovidername') if self[:serviceautostartprovidername] && !(self[:serviceautostartprovidertype])

    raise('Must specify serviceautostartprovidername as well as serviceautostartprovidertype') if self[:serviceautostartprovidertype] && !(self[:serviceautostartprovidername])

    provider.validate if provider.respond_to?(:validate)
  end

  def munge_boolean(value)
    case value
    when true, 'true', :true
      :true
    when false, 'false', :false
      :false
    else
      raise('munge_boolean only takes booleans')
    end
  end
end
