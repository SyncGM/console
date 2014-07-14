SES Console: Macro Package
===============================================================================

Summary
-------------------------------------------------------------------------------
  This directory contains a set of default macros which are designed to be used
with the SES Console. These macro files define a number of common tasks which
may be useful while play-testing or debugging games made with RPG Maker VX
Ace.

  While these macros are relatively minimalistic, they provide an example of
how to write effective macro files and provide some basic environment set up
which should prove useful to most developers.

Usage
-------------------------------------------------------------------------------
  Each macro provides information about its usage, but there are two files
which are particularly important: 'setup.rb' and 'autoload/extensions.rb'.

  The provided 'setup.rb' file performs a lot of console environment set up,
not the least of which is the automatic evaluation of the macro files placed in
the 'autoload/' directory -- by default, the files placed in this directory
will be evaluated only the **first** time that the SES Console is opened; as
such, this is where to place files which set up an environment or otherwise
perform tasks that only need to be run a single time per test run.

  As an example of a file to place in 'autoload/', the 'extensions.rb' file
defines a number of extensions to the core Ruby environment used by RPG Maker
VX Ace. Most notably, it defines methods in the `Kernel` module which delegate
to the appropriate method in `SES::Console` (notably `bind`, `rebind`, `macro`,
and `multiline`), which allows these methods to be used anywhere without having
to provide the full `SES::Console` namespace. It also defines a number of
methods on the core Ruby modules and classes which enhance debugging with the
SES Console, so please consult that file for more information about what it
offers.

Downloading
-------------------------------------------------------------------------------
  The latest downloadable package of macro files should be available from the
GitHub repository for the console under the Releases tab. Each release which
includes this macro package will have a .zip file attached to it for immediate
download. This archive provides the entire macro package ready for deployment
to the `MACRO_DIR` directory as configured in the main SES Console script.

  * [SES Console Releases](https://github.com/sesvxace/console/releases)