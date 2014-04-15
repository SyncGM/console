
Console v1.1 by Solistra and Enelvon
=============================================================================

Summary
-----------------------------------------------------------------------------
  This script provides an interactive Ruby console through the RGSS Console
with support for user-defined macros (stored as external files), multiple
lines of input, and the ability to step into and out of any Ruby object known
at runtime. This is primarily a scripter's tool.

Advanced Usage
-----------------------------------------------------------------------------
  In order to activate the console, press F5 (by default -- this is able to
configured in the configuration area). By default, one line of code is
evaluated at a time. To stop the interactive interpreter and return to the
game, simply use the `exit` method provided by the `Kernel` module.
(**NOTE:** If you are in the context of an object which has an alternative
`exit` method defined -- such as `SceneManager` -- you will have to call the
`Kernel.exit` method explicitly or raise a `SystemExit` exception.)

  In order to evaluate multiple lines, use the `Console.multiline` method and
`eval` its output like so:

    eval Console.multiline

  **NOTE:** The `Console.multiline` method simply takes multiple lines of
input and returns a string of the input -- it does not perform any evaluation
by itself. To end multiline input, simply enter the 'end of input' delimiter
(`<<` by default, though this can be configured below).

  The SES Console also allows you to change the context of the interactive
interpreter at any time by binding it to any present Ruby object with the
`Console.bind` method. For example, to bind the interpreter to event 5 on the
current map, use the following:

    Console.bind($game_map.events[5])

  All code entered into the interpreter from that point on would be evaluated
in the context of event 5 on the current map. You can also bind the console
to the top-level Ruby execution context by passing the Main constant to the
`Console.bind` method, which will evaluate code in Main. To rebind the
console back to the `SES::Console` module, use the method `Console.rebind`.

  In addition to this, the SES Console allows the use of external Ruby files
known as 'macros.' These files must be stored in the configurable `MACRO_DIR`
directory in your project's root directory. Each macro must have a unique
filename ending in the '.rb' file extension to be recognized by this script.
Macros may also be placed in subdirectories for organization, but filenames
*must* be unique. In order to execute an external macro, use the method
`Console.macro` with a symbol corresponding to the base name of the external
macro you wish to use. For example, to call the macro 'Files/read_file.rb',
use the following:

    Console.macro(:read_file)

  **NOTE:** New macros added to the `MACRO_DIR` directory while the game is
run in test mode will *not* be found automatically. If this occurs, you will
have to rebuild the macro listing by calling the `Console.load_macros`
method. Once called, all detected macros will be added to the `@macros` hash.

  **NOTE:** Two macros have special functionality: 'setup' and 'teardown'.
The 'setup' macro is run whenever the SES Console is opened via its `open`
method, and the 'teardown' macro is run whenever the opened console has been
exited. Use these macros for any code you want to be run whenever the console
is opened or exited by user or script input.

  As a final note, the console can also be used in a non-interactive mode by
opening the console and passing a string to be immediately evaluated. This
will run the passed string as if it were entered as input by an interactive
user and then end console processing. This can be done by entering code into
an event's Script Call command like so:

    Console.open(%{puts 'Hi, there.'})

  You can also perform 'silent' evaluations (essentially, evaluation without
the displayed return value) by passing a string to the `Console.evaluate`
method directly with a second argument of `true` to enable silent evaluation.
Example (in a Script Call):

    Console.evaluate(%{puts 'Hi, there.'}, true)

  **NOTE:** The `nil` return value of the `puts` method is suppressed... but
keep in mind that this suppresses the display of exceptions, too.

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

