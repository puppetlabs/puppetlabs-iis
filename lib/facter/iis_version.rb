Facter.add("iis_version") do
 confine :kernel => :windows
  setcode do
    begin
      require 'win32/registry'
      ACCESS_TYPE = Win32::Registry::KEY_READ | 0x100
      HKLM        = Win32::Registry::HKEY_LOCAL_MACHINE
      REG_PATH    = 'SOFTWARE\Microsoft\InetStp'
      REG_KEY     = 'VersionString'
      
      iis_ver = nil
      HKLM.open(REG_PATH, ACCESS_TYPE) do |reg|
        iis_ver = reg[REG_KEY]
      end
     
      if iis_ver.match(/^Version (\d+\.\d+)$/) then
        iis_ver = $1
      else
        iis_ver = iis_ver[8,3] # Incorrectly reads 10.0 as 10.
      end
    rescue
      iis_ver = ""
    end
    iis_ver
  end
end
