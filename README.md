# Deryls Testing Framework

Plugable framework for testing shell scripts (at least now).

## Usage

    $ gem install dtf
    $ dtf <path/to/file>_comment_test.sh

## Comment tests

Filename has to end with _comment_test.sh

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
- match=/<regexp>/ - regexp match command output
- env[<var_name>]=/<regexp>/ - regexp match the given environment variable name

## Example

    $ bin/dtf example_tests/comment/*
    F..
    ##### Processed commands 2 of 2, success tests 2 of 3, failure tests 1 of 3.
    $ false
    # failed: status = 0 # was 1

## Internal architecture

Framework will load plugins from any available gem and local `lib/` path, for example:

    lib/plugins/dtf/text_output.rb
    lib/plugins/dtf/status_test.rb
    lib/plugins/dtf/comment_test_input.rb

The search pattern is:

    lib/plugins/dtf/*.rb

And plugins are selected with:

    lib/plugins/dtf/*_{input,test,output}.rb
