#--
# SES Console: Run
# =============================================================================
#   Runs a user-given command through the command shell.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Execute the macro.
  print(@prompt)
  Shell.execute(gets.chomp!)
end