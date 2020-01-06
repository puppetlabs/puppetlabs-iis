# The Puppet Extensions Module
module PuppetX::PuppetLabs::IIS
  # Bindings class
  class Bindings
    def self.sort_bindings(b)
      if b.nil?
        []
      else
        b.sort_by { |a| ((a['protocol'] == 'https') ? '0' : '1') + a['bindinginformation'] }
      end
    end
  end
end
