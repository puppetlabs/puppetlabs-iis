module PuppetX
  module PuppetLabs
    module IIS
      class IISVersion
        def self.supported_version_installed?
          false
        end
      end
    end
  end
end

if Puppet::Util::Platform.windows?
  require 'win32/registry'
  module PuppetX
    module PuppetLabs
      module IIS
        class IISVersion

          def self.supported_versions
            ['7.5', '8.0', '8.5','10.0']
          end

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

            rescue Exception => e
              version = nil
            end
            version
          end

          def self.supported_version_installed?
            supported_versions.include? installed_version
          end

        end
      end
    end
  end
end
