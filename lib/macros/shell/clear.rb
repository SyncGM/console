#--
# SES Console: Clear
# =============================================================================
#   Clears the screen using the appropriate system shell command.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Execute the macro.
  Shell.execute('cls')
end