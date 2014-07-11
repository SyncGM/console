#--
# SES Console: Write File
# =============================================================================
#   Writes the given multiple-line input to the specified file.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # ===========================================================================
  # Files
  # ===========================================================================
  # Provides logic for macros which operate on files.
  module Files
    # Writes the given contents to the given file name. Writes to the last file
    # operated on if the given file name is an empty string.
    # 
    # @param file [String] the file to write
    # @param contents [String] the contents to write to the given file
    # @return [String] the contents of the file written to
    def self.write_file(file, contents)
      assign_last(file)
      begin
        File.open(@last, 'w') { |f| f.write(contents) }
        File.read(@last)
      rescue
        nil
      end
    end
  end
  
  # Print the prompt and execute the macro.
  print(Files.prompt)
  Files.write_file(gets.chomp!, SES::Console.multiline)
end