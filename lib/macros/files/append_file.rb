#--
# SES Console: Append File
# =============================================================================
#   Appends the given multiple-line input to the specified file.
#++
module SES::Console::Macros
  # ===========================================================================
  # Files
  # ===========================================================================
  # Provides logic for macros which operate on files.
  module Files
    # Appends the given contents to the given file name. Returns the contents
    # of the appended file. Appends to the last file operated on if the given
    # file name is an empty string.
    def self.append_file(file, contents)
      assign_last(file)
      File.open(@last, 'a') { |f| f.write(contents) }
      File.read(@last)
    end
  end
  
  # Print the prompt and execute the macro.
  print(Files.prompt)
  Files.append_file(gets.chomp!, SES::Console.multiline)
end