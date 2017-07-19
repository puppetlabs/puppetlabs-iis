module PuppetX
  module PuppetLabs
    module IIS
      module Property
        class Path < Puppet::Property
          validate do |value|
            if value.nil? or value.empty?
              raise ArgumentError, "A non-empty #{self.name.to_s} must be specified."
            end
            # C:\directory or \\SERVER\share
            fail("#{self.name.to_s} must be an absolute or UNC path, not '#{value}'") unless value =~ /^.:(\/|\\)/ or value =~ /^\\\\[^\\]+\\[^\\]+/
          end
	end
      end
    end
  end
end