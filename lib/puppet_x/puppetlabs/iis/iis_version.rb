# The Puppet Extensions Module
module PuppetX
  # PuppetLabs
  module PuppetLabs
    # IIS
    module IIS
      # IISVersion
      class IISVersion
        def self.supported_version_installed?
          false
        end
      end
    end
  end
end
if Puppet::Util::Platform.windows?
  # util
  require 'win32/registry'
  # The Puppet Extensions Module
  module PuppetX
    # PuppetLabs
    module PuppetLabs
      # IIS
      module IIS
        # IISVersion
        class IISVersion
          # define iis supported_versions
          def self.supported_versions
            ['7.5', '8.0', '8.5', '10.0']
          end

          # get iis installed_version
          def self.installed_version
            version = nil
            begin
              hklm        = Win32::Registry::HKEY_LOCAL_MACHINE
              reg_path    = 'SOFTWARE\Microsoft\InetStp'
              access_type = Win32::Registry::KEY_READ | 0x100

              major_version = ''
              minor_version = ''

              hklm.open(reg_path, access_type) do |reg|
                major_version = reg['MajorVersion']
                minor_version = reg['MinorVersion']
              end

              version = "#{major_version}.#{minor_version}"
            rescue StandardError
              version = nil
            end
            version
          end

          # verify if iis supported version is installed
          def self.supported_version_installed?
            supported_versions.include? installed_version
          end
        end
      end
    end
  end
end
