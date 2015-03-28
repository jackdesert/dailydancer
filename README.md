DailyDancer
===========

Daily Dancer is a Sinatra app that accepts emails via HTTP POST from a
provider such as http://cloudmailin.com, stores them in an sqlite database,
decides which emails represent *events*, and displays those events on a
calendar.


Working Example
---------------

The original site is in use at http://dailydancer.jackdesert.com.


Running the Tests
-----------------

    bundle exec rspec


Manually Firing Emails via HTTP
-------------------------------

You can use `bin/http_agent.rb` to fire emails at your server using the expected format.


Inspect
-------

    $ be ruby pry
    > require './helper'


Migrations
----------

You will need to migrate the development and production databases manually.
(The test database calls migrations from spec/spec_helper automatically)

To run a specific migration against a particular environment:

    RACK_ENV=<environment> bundle exec pry
    [1] pry(main)> require './helper'
    [1] pry(main)> require './db/migrations/<name_of_migration>'


Running the server in Development Mode
--------------------------------------

    bundle exec rerun 'rackup config-dancer.ru -o 0.0.0.0' --background

Note the -o 0.0.0.0 is only necessary if you are running inside a VM


Running the server in Production Mode
-------------------------------------

    nohup script/run_dancer_indefinitely.sh &


Setting up your mailing list
----------------------------

Sign up for an account at cloudmailin.com. Get a cloudmailin email address. Make sure your production
server is up and running. Subscribe your cloudmailin email address to your mailing list, then go into the
sqlite database using the "Inspect" instructions above to retrieve the verification link so you can prove
to your list serve that it's really your address. Then it's ready to go.


Viewing All Messages in Reverse Chronological Order
---------------------------------------------------

This view, while not intended for public consumption, lets you
sanity check that messages with dates in them show up on the correct day

    localhost:9292/admin/messages


Viewing Duplicates
------------------

This view shows duplicates in a different color so you can see what is being filtered out

    localhost:9292/?admin=true


Manually Hiding Messages
------------------------

    Message.find(id: <id>).hide('<reason>')

Roadmap
--------------

COMPLETED:

  * Confirmed Util.current_date_in_portland works correctly before and after midnight
  * Hyperlinks are clickable
  * robots.txt opts out of search engines
  * /admin/messages allows a view into which messages are being picked up
  * Add negative lookahead expression that knows "march 2010" is not an event.
  * Correctly identify date when for Re: and Fw: in conjunction with 'on Friday, Nov 6 at 12:29pm so and so wrote ...'
  * Animations when clicking on subject
  * Text still selectable without activating animation
  * FAQ page with link to it
  * Responsive design using lightweight tools
  * Recognize "This Friday" in subject as an event
  * Use subject, author, and plain to determine duplicates, and only show latest if duplicate
  * Manual hiding of messages using the :hidden database colum


PASSIONATE ABOUT:

  * Beautiful rendering of email content (possibly using html and parsing out custom styles)


PRETTY WARM ABOUT:

  * Link for "show me more" that shows lots of events
  * If two dates in body, choose the first one AFTER received-at
  * Do not display "Move in as soon as May 1st." as an event
  * Advertise it among friends
  * Advertise on facebook list
  * Improve FAQ to include what it includes / doesn't include
  * Improve FAQ to include "What is this again?"
  * Spot-on styling and positioning on Android and iPhone (especially nav tabs)
  * Complete Rationale idea

SEEMS LIKE A GOOD IDEA:

  * Blacklist the AstrologyNow Forecast
  * Ask HEBA to design the FAQ page for me
  * Fix so can pull down latest database
  * Redirect from www to naked domain (sinatra does not see the www)
  * Return the id when creating a message so cloudin can see it
  * Cache assets so they do not need requesting again
  * Test in IE8
  * Make response times faster (0.25 seconds with 120 entries)
  * Add to readme how to set up cloudmailin

NOT SO SURE ABOUT:

  * Add a url parameter for displaying N number of days
  * Scroll to top whenever page is reloaded
  * Inline scripts and stylesheets in production mode so only one network hit
  * Make a /jack page that tells about the author, and link to it instead of giving a mailto
  * Make sure received-at is converted to the correct day (Pacific time) when used to parse relative dates in subjects
  * (Jennifer, Nicholas) What about putting posting guidelines in the FAQ how to make sure the event is found?
  * register pdxdailydancer.com
  * Staging site
  * Build an interactive thing that displays a message and asks if the correct date has been found, then saves
    the "confirmed_date" so it is easy to test whether they are all correctly identified.
  * Investigate Zepto
  * Load Testing
  * Using the artwork from one of the fiverr artists (in /doc/artwork)

NEEDS PRIORITIZATION

  * Allow google to index either the faq page or the main page (without events)
  * collect unique IP addresses via (redis?) by date
  * Set up automatic database archiving
  * Print out slips of cardstock that have daily dancer address
  * Talk with Abigail about ways to get more mindshare around DailyDancer
  * Only load messages that arrived within the last 30 days. (And use an index on received at)
  * Make it faster (loading in 0.6 seconds). index on hidden? store parsed date? Memcached?
  * Do not show "register by April 1"
  * Search in subject + plain for date


Notes from my Sweetheart:
  * Can it bring in things from the facebook list too?
  * What about the weekly things? Why isn't next wednesday's dance on here yet?
  * Can we put the first four lines of the body?
  * How do I know who posted this? It makes a big difference to me.
  * Location, time? Are those hard?
  * I notice that a four-day event only shows up on the first day of that event...
  * How about a note, "automatically culled from..."
  * Votes for ten days' worth
  * If button for "show more", then can it be a big button?
  * If two emails for same event, how can I know which one is more recent?
  * What about really juicy events that are announced six weeks ahead and that will fill up fast? Do
    I want that to show up in DD?
  * When show-more button opens, can it go ALL THE WAY into the future.
