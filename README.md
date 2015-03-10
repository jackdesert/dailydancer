
Daily Lager
===========

"It's good for you", she said.

"How good for me? *Measureably* good?"

Daily Lager allows the tracking of your own custom, statistical data about
yourself via a simple DSL over SMS or command line. Once you acquire enough
data about your consumption or non-consumption of those garden greens, and
data on how great (or not great) you feel each day, you can answer that last
question for yourself.



The DSL
-------
  Available commands:
        MENU
        LIST
        TODAY
        YESTERDAY
        NOTE <body>
        LAST <category>
        CREATE <category> [DEFAULT <integer>]
        RENAME <category_name> <new_name>
        DELETE <category>
        HISTORY | WEB
        [Y] [<integer>] <category>


    MENU
      # Displays a list of available commands

    LIST
      # Shows a list of categoriess you are tracking

    CREATE <category> [DEFAULT <integer>]

    DELETE <category>
      # Deletes a category you're tracking

    HISTORY | WEB
      # Provides a link to a graphical representation of your history
      # and a link to to a web interface for fast response time

    TODAY
      # Shows all the categoriess you've logged today

    YESTERDAY
      # Shows all the categoriess you logged yesterday

    NOTE <body>
      # Creates a note in the system for today's date. This is useful for noting
      # occurrences that are not necessarily numerical series

    LAST <category>
      # Show how long it has been since last occurrence of <category>

    UPDATE DEFAULT <category> <new_name>
      # Update the default value of somecategory you're tracking

    RENAME <category> <new_name>
      # Change the name (and hence the DSL) of somecategory you're tracking

    <integer> <category_name>
      # Logs a single piece of data for today's date with a value of <integer>

    Y <integer> <category_name>
      # Logs a single piece of data for yesterday's date with a value of <integer>

    <category_name>
      # Logs a single piece of data for today's date with a value of 1

    Y <category_name>
      # Logs a single piece of data for yesterday's date with a valueof 1



Interactive Demo
---------------------------------------

Try out the Demo. It's an ncurses simulation of Daily Lager being run over SMS.

First install Ruby 2.x, then run:

    bundle exec ruby demo.rb

It looks like this:

        ┌-------------------------------------------┐
        |                                           |
        |  Welcome to the Daily Lager Demo

        Available commands:
        MENU
        LIST
        TODAY
        YESTERDAY
        NOTE <body>
        CREATE <category> [DEFAULT <integer>]
        RENAME <category_name> <new_name>
        DELETE <category>

        To close the demo, CTRL-C                   |
        |                                           |
        └-------------------------------------------┘

You can use the DSL to create a category named *carrots*

        ┌-------------------------------------------┐
        |                                           |
        |  create carrots                           |
        |                                           |
        └-------------------------------------------┘
        ┌-------------------------------------------┐
        |                                           |
        |  Category 'carrots' created.              |
        |                                           |
        └-------------------------------------------┘

And then you can log your carrot consumption

        ┌-------------------------------------------┐
        |                                           |
        |  3 carrots                                |
        |                                           |
        └-------------------------------------------┘
        ┌-------------------------------------------┐
        |                                           |
        |  3 carrots(s) logged.                     |
        |                                           |
        └-------------------------------------------┘


More Examples
-------------
Let's say you want to log how many miles you walk, how many days
you take your B vitamins, and how much you sleep.

    Create a category called 'walk':
      CREATE walk
        => 'walk' created

    Create a category called 'sleep':
      CREATE sleep
        => 'sleep' created

    Create a category called 'vitamins' with a default value of 1:
      CREATE vitamin DEFAULT 1
        => 'vitamin' created with a default value of 1

    Ask what categories are loaded:
      LIST
        => category you're tracking:
           sleep
           vitamin (default 1)
           walk

    Log that you walked two (miles) today:
      2 walk
        => Logged 2 walk(s)

    Log that you slept 6 hours today:
      6 sleep
        => Logged 6 sleep(s)

    Log that you walked six more miles (still the same day)
      walk
        => Logged 1 walk(s), total today: 3

    Ask what's been logged today:
      TODAY
        =>  Today's totals:
            6 sleep
            1 vitamin
            3 walk

    Note that school started today
      NOTE School started
        => Noted: 'school started'


A Note About UPPERCASE
----------------------

In this documentation, Uppercase letters are used to better highlight which words are keywords.
However, you can enter them as either upper or lower case (or a mixture of both).


What Data is Logged
-------------------

Each category gets a default entry for each day. If you
don't set a default value, then the default value is 0.
Whenever you log some category using the DSL, it creates
an additional entry for that category, with the value
you provided. When you ask for your daily totals, it
adds them up for you.


Negative Numbers
----------------

All categories that you log are additive. For example, if your
default value for a category is 10 but today you want to record
'8' instead, just log '-2'. That will set the day's totals to 8.


Data Mining
-----------

Once you have enough data, you can determine whether those green
vegetables you've started eating are really decreasing the
frequency of your hiccups when you train for your marathon.

Some simple queries are available through the DSL, such as
TODAY and YESTERDAY.

For a visual display of your data, open your browser and
point it to '/'

For more complex analyses, get your SQL hackery on!


Updating this README File
------------------------

This README file is generated from doc/README.md.erb. To generate
the file, run

    erb doc/README.md.erb > README.md


Running the Tests
-----------------

    bundle exec rspec


Migrations
----------

To start the demo environment again, just remove db/demo.db and run the demo again.

To run a specific migration against a particular environment:

    RACK_ENV=<environment> pry
    [1] pry(main)> require './daily_lager'
    [1] pry(main)> require './db/migrations/<name_of_migration>'


Running the server in Development Mode
--------------------------------------

    bundle exec rerun 'rackup config-daily_lager.ru -p 8853' --background

Running the server in Production Mode
-------------------------------------

    nohup script/run_daily_lager_indefinitely.sh &

Roadmap
--------------

Completed:

  * Chain of Responsibility pattern to determine which subclass of Verb is appropriate for a given input
  * Human model corresponds to a user
  * Thing model corresponds to a category
  * Occurrence model corresponds to a single piece of data logged
  * Textual output for each subclass of Verb is unit tested
  * Demo (demo.rb) lets you interact with the DSL without a server
  * Before logging new data, it backlogs any days with no data
    with the default values
  * Allow multiple users to access the same Sinatra instance,
    identified by phone number
  * Added a durable storage mechanism using the sequel gem
  * Connect to Twilio via Sinatra for a single user
  * Supports multiple users via Human.find_or_create()
  * Allows backfilling data for yesterday
  * UPDATE DEFAULT functionality added
  * View history in browser
  * Notes can be added to a date
  * Display dates in browser
  * Display notes in browser
  * LastVerb implemented
  * Shortcut words implemented (default value is 1 if no value given)
  * Allow integer and category to be swapped
  * Intelligently say '1 run' and '2 runs'
  * Added HistoryVerb for secure access to your own history
  * Added web interface

Backlog:

  * Show trends in R
  * Complete DELETE functionality
  * Beef up model validations
  * Add database validations to ensure referential integrity

Icebox:

  * Add verbs for WEEK, LAST WEEK, MONTH, LAST MONTH, YEAR, and <year>


