module PuppetX
  module PuppetLabs
    module IIS
      module Property
        class Path < Puppet::Property
          validate do |value|
            if value
              unless value =~ /^.:(\/|\\)/ or value =~ /^\\\\[^\\]+\\[^\\]+/
                # (c:\directory or c:/directory) or \\server\share
                fail("#{self.name.to_s} should be a Path (Absolute or UNC) not '#{value}'")
              end
            end
          end
        end
      end
    end
  end
end