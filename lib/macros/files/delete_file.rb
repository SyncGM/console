#--
# SES Console: Delete File
# =============================================================================
#   Deletes the specified list of files.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Files
  # ===========================================================================
  # Provides logic for macros which operate on files.
  module Files
    # Deletes files referenced by the given file names.
    # 
    # @param files [Array<String>] a list of file names to delete
    # @return [FixNum] the number of files deleted
    def self.delete(*files)
      assign_last(*files)
      File.delete(*(files.empty? ? [@last] : files))
    end
  end
  
  # Print the prompt and execute the macro.
  print("File names (comma separated, blank for #{Files.last}) #{@prompt}")
  Files.delete(*gets.chomp!.split(/,\s+/))
end