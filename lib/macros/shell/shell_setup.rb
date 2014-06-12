#--
# SES Console: Shell Setup
# =============================================================================
#   Opens an underlying shell within the SES Console.
#++
module SES::Console::Macros
  module Shell
    class << self
      # The executable to use as the shell.
      attr_accessor :exe
    end
    
    # Assign the Command Prompt as the default shell.
    @exe ||= 'cmd.exe'
    
    # Opens the defined shell, executes the given input, then closes the shell.
    # The shell will remain open until exited if no input is explicitly given.
    def self.execute(input = nil)
      system(input || @exe)
    end
  end
end