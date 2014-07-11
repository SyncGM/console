#--
# SES Console: Through
# =============================================================================
#   Toggles the `through` state of the player.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Player
  # ===========================================================================
  # Provides macros which operate on the player directly.
  module Player
    # Toggles the `through` state of the player.
    # 
    # @return [Boolean] whether the player's `through` state is active
    def self.toggle_through
      $game_player.instance_variable_set(:@through, !$game_player.through)
    end
  end
  
  # Execute the macro.
  Player.toggle_through
end