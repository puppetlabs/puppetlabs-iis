Facter.add("iis_version") do
 confine :kernel => :windows
  setcode do
    iis_ver = nil
    begin
      require 'win32/registry'
      access_type = Win32::Registry::KEY_READ | 0x100
      hklm        = Win32::Registry::HKEY_LOCAL_MACHINE
      reg_path    = 'SOFTWARE\Microsoft\InetStp'
      reg_key     = 'VersionString'
      
      iis_version_text = ''
      hklm.open(reg_path, access_type) do |reg|
        iis_version_text = reg[reg_key]
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
