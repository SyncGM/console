#--
# SES Console: Read File
# =============================================================================
#   Reads and returns the contents of a given file.
#++
module SES::Console::Macros
  # ===========================================================================
  # Files
  # ===========================================================================
  # Provides logic for macros which operate on files.
  module Files
    # Reads and returns the contents of the given file. Reads the contents of
    # the last file operated on if no file reference is given.
    def self.read_file(file)
      assign_last(file)
      File.read(@last) rescue nil
    end
  end
  
  # Print the prompt and execute the macro.
  print(Files.prompt)
  Files.read_file(gets.chomp!)
end