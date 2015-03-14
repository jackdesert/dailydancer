Dancer
======


Inspect
=======

    $ be ruby pry
    > require './helper'

Running the Tests
-----------------

    bundle exec rspec


Migrations
----------

To run a specific migration against a particular environment:

    RACK_ENV=<environment> bundle exec pry
    [1] pry(main)> require './helper'
    [1] pry(main)> require './db/migrations/<name_of_migration>'


Running the server in Development Mode
--------------------------------------

    bundle exec rerun 'rackup config-dancer.ru -o 0.0.0.0' --background

If you are running it in a VM and can't access it from the host OS,
add

    -o 0.0.0.0

to the command

Running the server in Production Mode
-------------------------------------

    nohup script/run_dancer_indefinitely.sh &

Roadmap
--------------

Completed:

  *

Backlog:

  *

Icebox:

  *


