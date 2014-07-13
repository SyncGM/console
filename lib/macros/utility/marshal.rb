#--
# SES Console: Marshal
# =============================================================================
#   Serializes a Ruby object to the given file name.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Utility
  # ===========================================================================
  # Provides macros which perform various utility operations.
  module Utility
    # Serializes a Ruby object to the given file name.
    # 
    # @param file [String] the file to serialize data to
    # @param object [Object] the object to serialize
    # @return [File] the file object serialized to
    def self.save_data(file, object)
      File.open(file, 'wb') { |file| file << Marshal.dump(object) }
    end
  end
  
  # Obtain the requested object through SES Console evaluation.
  print('Object ' << @prompt)
  object = SES::Console.evaluate(gets.chomp!, true)
  
  # Obtain the desired filename. A '.rvdata2' extension is appended to the file
  # name unless it already has one.
  print('File   ' << @prompt)
  file = gets.chomp!
  file << '.rvdata2' unless file =~ /\.rvdata2$/
  
  # Execute the macro.
  Utility.save_data(file, object)
end