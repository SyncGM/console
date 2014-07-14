#--
# SES Console: Restore Events
# =============================================================================
#   Restores all killed events to the current map.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Utility
  # ===========================================================================
  # Provides macros which perform various utility operations.
  module Utility
    # Restores all of the events on the current map.
    # 
    # @note This method may be called when the scene is not an instance of
    #   `Scene_Map` and will still perform the appropriate action.
    # 
    # @return [Hash{FixNum => Game_Event}] hash of events on the current map
    def self.restore_events
      $game_map.setup_events
      SceneManager.call(Scene_Map) if SceneManager.scene_is?(Scene_Map)
      $game_map.events
    end
  end
  
  # Execute the macro.
  Utility.restore_events
end