#--
# SES Console: Transfer
# =============================================================================
#   Transfers the player to the given map name or ID.
#++
module SES::Console::Macros
  # ===========================================================================
  # Player
  # ===========================================================================
  # Provides macros which operate on the player directly.
  module Player
    # Immediately transfers the player to the given map at the given X and Y
    # positions.
    def self.transfer(map_id, x, y)
      $game_player.reserve_transfer(map_id, x, y)
      $game_player.perform_transfer
    end
  end
  
  # Execute the macro.
  print('Map ID, X, Y ' << @prompt)
  Player.transfer(*gets.chomp!.split(/,\W+/).map(&:to_i))
end