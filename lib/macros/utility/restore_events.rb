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
    # Restores all of the killed events on the current map.
    # 
    # @note This method may be called when the scene is not an instance of
    #   `Scene_Map` and will still perform the appropriate action.
    # 
    # @return [Hash{FixNum => Game_Event}, nil] hash of events on the current
    #   map if events were restored, `nil` otherwise
    def self.restore_events
      map_events = $game_map.instance_variable_get(:@map).events
      return nil unless @events_killed == map_events
      $game_map.setup_events
      SceneManager.call(Scene_Map) if SceneManager.scene_is?(Scene_Map)
      @events_killed = nil
      $game_map.events
    end
  end
  
  # Execute the macro.
  Utility.restore_events
end