# The Puppet Extensions Module
module PuppetX
  # IIS
  module IIS
    # PowerShellCommon
    module PowerShellCommon
      # powershell_path returns powershell's path
      def powershell_path
        path = if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
                 "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
               elsif File.exist?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
                 "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
               else
                 'powershell.exe'
               end
        path
      end
      module_function :powershell_path

      # powershell_args can be ['-NoProfile', '-NonInteractive', '-NoLogo', '-ExecutionPolicy', 'Bypass']
      def powershell_args
        ps_args = ['-NoProfile', '-NonInteractive', '-NoLogo', '-ExecutionPolicy', 'Bypass']
        ps_args
      end
      module_function :powershell_args
    end
  end
end
