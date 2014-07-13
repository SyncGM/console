#--
# SES Console: Transfer
# =============================================================================
#   Transfers the player to the given map ID.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Player
  # ===========================================================================
  # Provides macros which operate on the player directly.
  module Player
    # Immediately transfers the player to the given map at the given X and Y
    # positions.
    # 
    # @param map_id [FixNum] the map ID to be transferred to
    # @param x [FixNum] the desired X position
    # @param y [FixNum] the desired Y position
    # @return [void]
    def self.transfer(map_id, x, y)
      $game_player.reserve_transfer(map_id, x, y)
      $game_player.perform_transfer
    end
  end
  
  # Execute the macro.
  print('Map ID, X, Y ' << @prompt)
  Player.transfer(*gets.chomp!.split(/,\W+/).map!(&:to_i))
end