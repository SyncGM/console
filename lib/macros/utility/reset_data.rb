#--
# SES Console: Reset Data
# =============================================================================
#   Resets all switches, variables, and self-switches to their default values.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Utility
  # ===========================================================================
  # Provides macros which perform various utility operations.
  module Utility
    # Resets all switches, variables, and self-switches to their default values
    # via their respective `#initialize` methods.
    # 
    # @return [Boolean] `true` if data was successfully reset
    def self.reset_data
      [$game_switches, $game_variables, $game_self_switches].each do |data|
        data.send(:initialize)
      end
      true
    end
  end
  
  # Execute the macro.
  Utility.reset_data
end