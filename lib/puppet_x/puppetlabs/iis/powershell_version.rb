# The Puppet Extensions Module
module PuppetX
  # PuppetLabs
  module PuppetLabs
    # IIS
    module IIS
      # PowerShell Version - determines the installed version of powershell
      class PowerShellVersion
      end
    end
  end
end

if Puppet::Util::Platform.windows?
  require 'win32/registry'
  module PuppetX
    module PuppetLabs
      module IIS
        # PowerShell Version - determines the installed version of powershell
        class PowerShellVersion
          # define ACCESS_TYPE
          ACCESS_TYPE       = Win32::Registry::KEY_READ | 0x100
          # define HKLM
          HKLM              = Win32::Registry::HKEY_LOCAL_MACHINE
          # define PS_ONE_REG_PATH
          PS_ONE_REG_PATH   = 'SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine'.freeze
          # define PS_THREE_REG_PATH
          PS_THREE_REG_PATH = 'SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine'.freeze
          # define REG_KEY
          REG_KEY           = 'PowerShellVersion'.freeze

          # returns powershell version
          def self.version
            powershell_three_version || powershell_one_version
          end

          # powershell_one_version
          def self.powershell_one_version
            version = nil
            begin
              HKLM.open(PS_ONE_REG_PATH, ACCESS_TYPE) do |reg|
                version = reg[REG_KEY]
              end
            rescue
              version = nil
            end
            version
          end

          # powershell_three_version
          def self.powershell_three_version
            version = nil
            begin
              HKLM.open(PS_THREE_REG_PATH, ACCESS_TYPE) do |reg|
                version = reg[REG_KEY]
              end
            rescue
              version = nil
            end
            version
          end
        end
      end
    end
  end
end
