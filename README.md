
Console v1.3 by Solistra and Enelvon
=============================================================================

Summary
-----------------------------------------------------------------------------
  This script provides an interactive Ruby console through the RGSS Console
with support for user-defined macros (stored as external files) and the
ability to step into and out of any Ruby object known at runtime. This is
primarily a scripter's tool.

  In addition to the core script, you may also download a zipped package of
default external macros which provide a number of useful tasks and general
enhancements to the basic SES Console. The latest macro package may be
downloaded from GitHub -- the latest release of the SES Console should have a
.zip archive attached to it which provides the entire macro package ready to
be placed in your configured macro directory. The package may be found here:

  * [SES Console Releases](https://github.com/sesvxace/console/releases)

Please be sure to read the included README.md file included with the package
for more information about what it offers.

Advanced Usage
-----------------------------------------------------------------------------
  In order to activate the console, press F5 (by default -- this is able to
be configured in the configuration area). By default, one line of code is
evaluated at a time. To stop the interactive interpreter and return to the
game, simply use the `exit` method provided by the `Kernel` module.

  **NOTE:** If you are in the context of an object which has an alternative
`exit` method defined -- such as `SceneManager` -- you will have to call the
`Kernel.exit` method explicitly or raise a `SystemExit` exception.

  **NOTE:** You may also use the `exit!` method provided by `Kernel` to close
the game immediately directly from the console.

  The SES Console also allows you to change the context of the interactive
interpreter at any time by binding it to any present Ruby object with the
`SES::Console.bind` method. For example, to bind the interpreter to event 5
on the current map, use the following:

    SES::Console.bind($game_map.events[5])

  All code entered into the interpreter from that point on would be evaluated
in the context of event 5 on the current map. You can also bind the console
to the top-level Ruby execution context by passing `main` to the `bind`
method, which will evaluate code in Main. To rebind the console back to the
user-defined `CONTEXT`, use the method `SES::Console.rebind`.

  **NOTE:** You can also temporarily bind or rebind the SES Console's context
by passing a block to the `SES::Console.bind` and `SES::Console.rebind`
methods like so:

    self # => SES::Console
    SES::Console.bind(main) do
      # Evaluation inside the block now takes place within `main`.
      self # => main
    end
    self # => SES::Console

  In addition to this, the SES Console allows the use of external Ruby files
known as 'macros.' These files must be stored in the configurable `MACRO_DIR`
directory in your project's root directory. Each macro must have a unique
file name to be recognized by this script. Macros may also be placed in
subdirectories for organization, but file names *must* be unique. In order to
execute an external macro, use the method `SES::Console.macro` with a symbol
corresponding to the base name of the external macro you wish to use. For
example, to call the macro 'Files/read_file.rb', use the following:

    SES::Console.macro(:read_file)

  **NOTE:** New macros added to the `MACRO_DIR` directory while the game is
run in test mode will *not* be found automatically. If this occurs, you will
have to rebuild the macro listing by calling the `SES::Console.load_macros`
method. Once called, all detected macros will be added to the `@macros` hash.

  **NOTE:** Two macros have special functionality: 'setup' and 'teardown'.
The 'setup' macro is run whenever the SES Console is opened via its `open`
method, and the 'teardown' macro is run whenever the opened console has been
exited. Use these macros for any code you want to be run whenever the console
is opened or exited by user or script input.

License
-----------------------------------------------------------------------------
  This script is made available under the terms of the MIT Expat license.
View [this page](http://sesvxace.wordpress.com/license/) for more detailed
information.

Installation
-----------------------------------------------------------------------------
  Place this script below the SES Core (v2.0) script (if you are using it) or
the Materials header, but above all other custom scripts. This script does
not require the SES Core (v2.0), but it is recommended.

