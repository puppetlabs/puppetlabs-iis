# The Puppet Extensions Module
class PuppetX::PuppetLabs::IIS::Property::AuthenticationInfo < Puppet::Property
  desc 'Enable and disable authentication schemas. Note: some schemas require
        additional Windows features to be installed, for example windows
        authentication. This type does not ensure a given feature is installed
        before attempting to configure it.'
  valid_schemas = ['anonymous', 'basic', 'clientCertificateMapping',
                   'digest', 'iisClientCertificateMapping', 'windows']
  def insync?(is)
    should.reject { |k, v|
      is[k] == v
    }.empty?
  end
  validate do |value|
    raise "#{name} should be a Hash" unless value.is_a? ::Hash
    unless (value.keys & valid_schemas) == value.keys
      raise('All schemas must specify any of the following: anonymous, basic, clientCertificateMapping, digest, iisClientCertificateMapping, or windows')
    end
  end
end
