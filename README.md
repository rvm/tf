# Deryls Testing Framework

Plugable framework for testing shell scripts (at least now).

## Running

    $ bin/dtf example_tests/comment/true_comment_test.sh 

    ##### starting test true with 1 commands and 2 tests.
    $ true
    # passed: status = 0
    # passed: status != 1
    ##### finished test true.

## Architecture

Framework will load plugins from any available gem and local `lib/` path, for example:

    lib/plugins/dtf/text_output.rb
    lib/plugins/dtf/status_test.rb
    lib/plugins/dtf/comment_test_input.rb

The search pattern is:

    lib/plugins/dtf/*.rb

And plugins are selected with:

    lib/plugins/dtf/*_{input,test,output}.rb
