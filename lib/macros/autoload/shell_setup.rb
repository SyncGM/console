#--
# SES Console: Shell Setup
# =============================================================================
#   Opens an underlying shell within the SES Console.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Shell
  # ===========================================================================
  # Provides logic for macros which operate through the command shell.
  module Shell
    class << self
      # The executable to use as the shell.
      # @return [String]
      attr_accessor :exe
      
      # The arguments to pass to the shell when called.
      # @return [String]
      attr_accessor :arguments
    end
    
    # Assign the Command Prompt as the default shell.
    @exe ||= 'cmd.exe'
    
    # Assign a custom prompt in the style of the SES Console.
    @arguments ||= '/k prompt $p$_$$$G$s'
    
    # Opens the defined shell, executes the given input, then closes the shell.
    # The shell will remain open until exited if no input is explicitly given.
    # 
    # @param input [String, nil] the input to execute; `nil` to execute user
    #   input
    # @return [Boolean] `true` if the shell exited cleanly, `false` otherwise
    def self.execute(input = nil)
      system(input || @exe + ' ' << @arguments)
    end
  end
end