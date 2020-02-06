/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

    The data you need is in the "country_club" database. This database         
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

select name from Facilities where membercost != 0 ; 

/* Q2: How many facilities do not charge a fee to members? */

select count(facid) from  Facilities where membercost = 0 ; 

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

select facid, name, membercost, monthlymaintenance from Facilities where membercost < (monthlymaintenance * 0.2); 

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

select * from Facilities where facid IN (1,5); 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name, monthlymaintenance, "Expensive" as label from Facilities where monthlymaintenance > 100
UNION
select name, monthlymaintenance, "Cheap" as label from Facilities where monthlymaintenance < 100; 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

select firstname , surname from Members  where str_to_date(joindate,'%Y-%m-%d %H:%I:%s') = (select max(str_to_date(joindate,'%Y-%m-%d %H:%I:%s')) from Members);

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

select Facilities.name, concat( Members.firstname,Members.surname) as memname_facility from Facilities , Members where Facilities.facid in   ( select Bookings.facid  from Bookings where Bookings.facid in (0,1)) order by Members.firstname;




/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

select Facilities.name, Facilities.guestcost * Bookings.slots as cost, concat( Members.firstname,Members.surname) as memname from Facilities , Members ,Bookings where Bookings.facid = Facilities.facid and Bookings.memid = Members.memid and Bookings.starttime like '%2012-09-14%' and Facilities.guestcost * Bookings.slots > 30 and Members.memid = 0
union
select Facilities.name, Facilities.membercost * Bookings.slots as cost, concat( Members.firstname,Members.surname) as memname from Facilities , Members ,Bookings where Bookings.facid = Facilities.facid and Bookings.memid = Members.memid and Bookings.starttime like '%2012-09-14%' and Facilities.membercost * Bookings.slots > 30 and Members.memid <> 0 order by cost desc;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

select New1.name, New1.cost * New1.slots as cost, concat(Members.firstname,Members.surname) as memname from Members, (select Bookings.slots as slots, Bookings.memid as memid, Facilities.name as name, Facilities.membercost as cost from Bookings, Facilities where Facilities.facid = Bookings.facid and Bookings.memid <>0 and Bookings.starttime like '%2012-09-14%' union
select Bookings.slots as slots, Bookings.memid as memid, Facilities.name as name, Facilities.guestcost as cost from Bookings, Facilities where Facilities.facid = Bookings.facid and Bookings.memid = 0 and Bookings.starttime like '%2012-09-14%') as New1 where New1.memid = Members.memid and New1.cost * New1.slots > 30 order by cost desc;


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select Rev.fac_name as Facility, Rev.revenue as Revenue from (select sum(new1.cost * new1.slots) as revenue, new1.fac_name from (select Facilities.membercost as cost, Bookings.slots as slots, Bookings.facid as facid, Facilities.name as fac_name from Facilities, Bookings where  Bookings.facid = Facilities.facid and Bookings.memid <> 0
union
select Facilities.guestcost as cost, Bookings.slots as slots, Bookings.facid as facid, Facilities.name as fac_name from Facilities, Bookings where Bookings.facid = Facilities.facid and Bookings.memid = 0) as new1 group by new1.facid) as Rev where Rev.revenue < 1000;



