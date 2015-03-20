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

