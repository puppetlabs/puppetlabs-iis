Facter.add("iis_version") do
 confine :kernel => :windows
  setcode do
    iis_ver = nil
    begin
      require 'win32/registry'
      ACCESS_TYPE = Win32::Registry::KEY_READ | 0x100
      HKLM        = Win32::Registry::HKEY_LOCAL_MACHINE
      REG_PATH    = 'SOFTWARE\Microsoft\InetStp'
      REG_KEY     = 'VersionString'
      
      iis_version_text = ''
      HKLM.open(REG_PATH, ACCESS_TYPE) do |reg|
        iis_version_text = reg[REG_KEY]
      end
      if iis_version_text.match(/^Version (\d+\.\d+)$/)
        iis_ver = $1
      end
    rescue
      iis_ver = nil
    end
    iis_ver
  end
end
