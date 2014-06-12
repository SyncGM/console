#--
# SES Console: Tree
# =============================================================================
#   Displays folder contents recursively using the appropriate system shell
# command.
#++
module SES::Console::Macros
  # Execute the macro.
  Shell.execute('tree /F')
end