#--
# SES Console: Tree
# =============================================================================
#   Displays folder contents recursively using the appropriate system shell
# command.
#++

# Macros
# =============================================================================
# Top-level namespace for the default SES Console macro package.
module SES::Console::Macros
  # Execute the macro.
  print(@prompt)
  Shell.execute('tree /F ' << gets.chomp!)
end