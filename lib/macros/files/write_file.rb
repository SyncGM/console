#--
# SES Console: Write File
# =============================================================================
#   Writes the given multiple-line input to the specified file.
#++
module SES::Console::Macros
  # ===========================================================================
  # Files
  # ===========================================================================
  # Provides logic for macros which operate on files.
  module Files
    # Writes the given contents to the given file name. Writes to the last file
    # operated on if the given file name is an empty string.
    def self.write_file(file, contents)
      assign_last(file)
      begin
        File.open(@last, 'w') { |f| f.write(contents) }
        File.read(@last)
      rescue ; nil end
    end
  end
  
  # Print the prompt and execute the macro.
  print(Files.prompt)
  Files.write_file(gets.chomp!, SES::Console.multiline)
end