#--
# SES Console: Delete File
# =============================================================================
#   Deletes the specified list of files.
#++
module SES::Console::Macros
  # ===========================================================================
  # Files
  # ===========================================================================
  # Provides logic for macros which operate on files.
  module Files
    # Deletes files referenced by the given file names.
    def self.delete(*files)
      assign_last(*files)
      File.delete(*(files.empty? ? [@last] : files))
    end
  end
  
  # Print the prompt and execute the macro.
  print("File names (comma separated, blank for #{Files.last}) #{@prompt}")
  Files.delete(*gets.chomp!.split(', '))
end