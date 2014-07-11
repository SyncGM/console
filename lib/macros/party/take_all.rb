#--
# SES Console: Take All
# =============================================================================
#   Takes all items, weapons, and armors defined in the database away from the
# party.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Party
  # ===========================================================================
  # Provides logic for macros which affect the party.
  module Party
    # Removes all gold and items from the party.
    # 
    # @return [Array<RPG::Item>] all items owned by the party
    def self.take_all
      gp = $game_party
      gp.lose_gold(gp.max_gold)
      # We're not using `init_all_items` here due to that method being designed
      # for item initialization, not subtraction -- as such, it is expected to
      # be redefined in some projects.
      gp.all_items.each { |i| gp.lose_item(i, gp.max_item_number(i)) }
      gp.all_items
    end
  end
  
  # Execute the macro.
  Party.take_all
end