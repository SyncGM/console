#--
# SES Console: Append File
# =============================================================================
#   Appends the given multiple-line input to the specified file.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Files
  # ===========================================================================
  # Provides logic for macros which operate on files.
  module Files
    # Appends the given contents to the given file name. Returns the contents
    # of the appended file. Appends to the last file operated on if the given
    # file name is an empty string.
    # 
    # @param file [String] the file to append to
    # @param contents [String] the contents to append
    # @return [String, nil] returns the contents of the file appended to if
    #   successful, `nil` otherwise
    def self.append_file(file, contents)
      assign_last(file)
      begin
        File.open(@last, 'a') { |f| f.write(contents) }
        File.read(@last)
      rescue
        nil
      end
    end
  end
  
  # Print the prompt and execute the macro.
  print(Files.prompt)
  Files.append_file(gets.chomp!, SES::Console.multiline)
end