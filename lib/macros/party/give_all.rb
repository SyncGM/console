#--
# SES Console: Give All
# =============================================================================
#   Gives all items, weapons, and armors defined in the database to the party.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Party
  # ===========================================================================
  # Provides logic for macros which affect the party.
  module Party
    # Gives the maximum amount of gold and all items to the party.
    # 
    # @return [Array<RPG::Item>] all items owned by the party
    def self.give_all
      gp = $game_party
      gp.gain_gold(gp.max_gold)
      [$data_armors, $data_items, $data_weapons].each do |data|
        data.each { |item| gp.gain_item(item, gp.max_item_number(item)) }
      end
      gp.all_items
    end
  end
  
  # Execute the macro.
  Party.give_all
end