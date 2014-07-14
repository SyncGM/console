#--
# SES Console: Backup
# =============================================================================
#   Creates a zip archive of the current project in its entirety without
# including previous backups.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Shell
  # ===========================================================================
  # Provides logic for macros which operate through the command shell.
  module Shell
    # Backup
    # =========================================================================
    # Provides logic for backing up project files through the command shell.
    module Backup
      class << self
        # The command to execute for backups.
        # @return [String]
        attr_accessor :command
        
        # The amount of compression to use. Valid values range from 0-9; higher
        # values produce better compression, but longer processing times.
        # @return [FixNum]
        attr_accessor :compression
      
        # The arguments to pass to the backup command.
        # @return [String]
        attr_accessor :arguments
      end
      
      # Use the packaged `7za` executable to perform backups.
      @command ||= "#{SES::Console::MACRO_DIR}/7za/7za"
      
      # Set the default compression level to 5.
      @compression ||= 5
      
      # Generates a file name for the backup archive.
      # 
      # @return [String] the archive file name
      def self.filename
        'Backups\\' << $data_system.game_title +
          " Backup #{Time.now.strftime('%m%d%Y %I%M%S')}.zip"
      end
      
      # Performs the backup operation through the command shell.
      # 
      # @return [Boolean] `true` if backup was successful, `false` otherwise
      def self.run
        Shell.execute(@command + ' ' << @arguments)
      end
      
      @arguments ||= \
        "a -r -mx#{@compression} -x!*Backup*.zip \"#{filename}\" *.*"
    end
  end
  
  # Execute the macro.
  Shell::Backup.run
end