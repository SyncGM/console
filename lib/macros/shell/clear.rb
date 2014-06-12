#--
# SES Console: Clear
# =============================================================================
#   Clears the screen using the appropriate system shell command.
#++
module SES::Console::Macros
  # Execute the macro.
  Shell.execute('cls')
end