Rationale
=========

Every decision made goes in this document, so we understand later WHY it is built the way it is.


Why Sqlite?
-----------

Sqlite was chosen because it is the simplest thing that meets the requirements, and
because Jack is familiar with using it in conjunction with


Why is only one model used?
---------------------------

Originally it was planned that multiple messages would reference the same event,
but in order to benefit from that, one must decide which messages are all for the
same event and decide which one to not display. It was simpler to display them both.
And looking back, if two are duplicates it still is easier to reference one message from
another than ti create an Event object and time them both to it

Also, the neat thing that fell out of using a single model is that when parsing the dates,
there is no need to write anything to the database. Which leads to the next question: Why
is the parsed date not stored in the database?


Why is the parsed date generated on the fly (as opposed to saved in the DB)
---------------------------------------------------------------------------

Largely because it is so easy to see the effects of using a new parsing algorithm. The algorithm
changed a few times in the beginning.


Why does Message.all get called? Is not that expensive?
-------------------------------------------------------

Yes it is expensive to call Message.all. In the beginning it was thought that eventually
the parsed date would be saved in the database, and therefore a cheaper query could be run
to get Message.future (all messages that reference events for today or in the future).

But as the database grows and it is not able to keep up with Message.all anymore, a simpler
strategy is to use Message.where('received_at > 1.month.ago') because
  A. This makes the problem of Message.all go away, as there are only about 300 messages
     received every month
  B. This makes it so that Chronic is only ever dealing with events near Date.today. Chronic
     is good with dates near itself. If Chronic parses "March 30" on a message that was received
     a year ago, it is going to assume this year for the year, which would be incorrect.
     Using Message.where('received_at > 1.month.ago') bypasses that problem, and also makes
     any issues around year-end go away. (When it is Dec 20th and an event comes through
     with "January 3", Chronic will know that to mean next year.)


Why is Event.load called in a thread?
-------------------------------------

The idea is the Event.load only gets called at most once per hour
and it does not need to be called inline. That is, any web traffic
will kick off the method call, but there is no need for the one who kicked
the job to reap its benefit. The next user will get the updated content, if any.


Why does Event.load delete all previous instances from the database?
--------------------------------------------------------------------

It is simpler to delete them than to compare them.


Why does DailyDancer pull from two sources?
-------------------------------------------

The dance community in Portland, Oregon has multiple streams of activities:
  * Mailing list
  * Web Site
  * Facebook
Some would love the facebook events shown here too. But it has not happened yet.


Why is the parameter xhr=true passed in with ajax requests?
-----------------------------------------------------------

The reason is twofold, but the first one is the clincher:
  * (originally) jQlite does not pass the appropriate header to tell Sinatra that request.xhr? is true
    but this does not apply any more now that it runs on jQuery proper
  * It makes is clear in the nxing logs which requests are xhr, since it uses the same controller


Why the switch to jQuery?
-------------------------

Because jQlite did not offer a way to unbind events.


Why is there a semaphore wrapped around Event.klass_last_loaded_at?
-------------------------------------------------------------------

Multiple server threads will access this data, and if they are out of sync,
two threads might attempt to Event.load, which means that momentarily there might be
a lot of events (new ones get created, and old ones get deleted)


Why is there not a lock on the Event table to prevent reading from it while new events are created?
---------------------------------------------------------------------------------------------------

Because the likelihood of a request coming in right at the moment when new events have been created but old
ones have not been deleted is small.


Why is there a sleep in Event.load?
-----------------------------------

To make sure the events do not get created before the request is serviced. (This is the most likely scenario why
someone would see duplicate Events)


Why is class << self used in MessagePresenter
---------------------------------------------

2015-04-09
Because it allows a class method to be defined that is actually private

Why is rack-cache used?
-----------------------
2015-04-11
To make responses faster

Why is disk being used to store rack-cache meta and data?
---------------------------------------------------------
2015-04-11
It was easier to use on disk than to start a memcached server


Why is the location of cache on disk in dancer/cache ?
------------------------------------------------------

2015-04-11
Because read/write access is known

Why is max_age set to 0?
------------------------

2015-04-11
It seems to be required in order to ever get a 304 back from the server.
Not setting it at all, the server always returns 200

Why does public/500.html have stylesheets inline?
-------------------------------------------------

Because if sinatra is down, the stylesheets are not available as files.

Why does public/500.html have no javascript files?
--------------------------------------------------

No AJAX requests are being made, and no animations need to happen
