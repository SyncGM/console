#--
# SES Console: Files Setup
# =============================================================================
#   Provides shared code for file macros.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Files
  # ===========================================================================
  # Provides logic for macros which operate on files.
  module Files
    class << self
      # Default prompt for file operations.
      # @return [String]
      attr_accessor :prompt
    end
    
    # Contains a reference to the last file operated on.
    # 
    # @return [String] the last file operated on
    def self.last
      @last ||= 'Unnamed.txt'
    end
    
    # Assign an appropriate default prompt for file operations.
    @prompt = "File name (blank for #{Files.last}) " <<
              "#{SES::Console::Macros.prompt}"
    
    # Assigns a reference to the last operated file to the @last instance
    # variable if applicable.
    # 
    # @param files [Array<String>] a list of files to operate on
    # @return [String] the last file operated on
    def self.assign_last(*files)
      file = files.reject { |file| file.empty? }.last
      @last = file unless file.nil?
      @last
    end
  end
  
  # Explicitly assign the last operated file to 'Unnamed.txt' if it has not yet
  # been assigned.
  Files.last
end