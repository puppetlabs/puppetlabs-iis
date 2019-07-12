# @api private
module PuppetX
  # @api private
  module IIS
    # PowerShellCommon
    module PowerShellCommon
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

      def powershell_args
        ps_args = ['-NoProfile', '-NonInteractive', '-NoLogo', '-ExecutionPolicy', 'Bypass']
        ps_args
      end
      module_function :powershell_args
    end
  end
end
