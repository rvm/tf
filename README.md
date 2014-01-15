# Testing Framework [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/mpapis/tf)

TF is a pluggable framework for testing shell scripts (at least now).
TF also is an umbrella which incorporates (eventually) multiple gems, each of which provides additional functionality
to TF. TF is the skeleton upon which all other tf-* gems build.


## Usage

    $ gem install tf
    $ tf <path/to/file>_comment_test.sh
    $ tf --text <path/to/file>_comment_test.sh

## Comment tests

Filename has to end with \_comment\_test.sh

Example test file:

    ## User comments start with double #
    ## command can be writen in one line with multiple tests:
    true # status=0; match=/^$/
    ## or tests can be placed in following lines:
    false
    # status=1

### Matchers

The test can be negated by replacing `=` with `!=`

- status=<number> - check if command returned given status (0 is success)
- match=/<regexp>/ - regexp match command output both stdout and stderr
- match[stdout|stderr]=/<regexp>/ - regexp match command either stdout or stderr
- env[<var_name>]=~/<regexp>/ - regexp match the given environment variable name
- env[<var_name>]?=[array|string|nil] - verify type of the given environment variable name
- env[<var_name>][]=<size> - verify size of the given environment variable name
- env[<var_name>][]=/<regexp>/ - regexp match all of elements of the given environment variable name
- env[<var_name>][<index>]=/<regexp>/ - regexp match given element of the given environment variable name

### Selecting shell / runner program

From version 0.3.1 Shebang lines are read and interpreted to select the runner shell.
Still only Bash / ZSH like shells are allowed.

## Example

    $ bin/tf example_tests/comment/*
    F..
    ##### Processed commands 2 of 2, success tests 2 of 3, failure tests 1 of 3.
    $ false
    # failed: status = 0 # was 1

    $ bin/tf example_tests/comment/* --text
    ##### starting test failure.
    $ false
    # failed: status = 0 # was 1
    ##### starting test success.
    $ true
    # passed: status = 0
    # passed: status != 1
    ##### Processed commands 2 of 2, success tests 2 of 3, failure tests 1 of 3.

## Troubleshooting

Use environment variable `TF_DEBUG` to enable additional logging:

    TF_DEBUG=1 tf --text  example_tests/comment/*

## Internal architecture

Framework will load plugins from any available gem and local `lib/` path, for example:

    lib/plugins/tf/text_output.rb
    lib/plugins/tf/status_test.rb
    lib/plugins/tf/comment_test_input.rb

The search pattern is:

    lib/plugins/tf/*.rb

And plugins are selected with:

    lib/plugins/tf/*_{input,test,output}.rb

## Thanks

 - Deryl R. Doucette
