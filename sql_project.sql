/* SQL Exercises */

/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name, membercost 
FROM country_club.Facilities
WHERE membercost != 0.0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) AS 'facilities_no_membercost'
FROM country_club.Facilities
WHERE membercost = 0.0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM country_club.Facilities
WHERE membercost != 0.0 AND (membercost/monthlymaintenance)<0.2

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM country_club.Facilities
WHERE facid IN (1,5) 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
	   CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	   ELSE 'cheap' END AS 'evaluation_monthlymaintenance'
FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT surname, firstname, joindate
FROM country_club.Members
WHERE joindate = (SELECT MAX(joindate) FROM country_club.Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(M.firstname,' ', M.surname) AS 'member_names(first/last)'
FROM country_club.Bookings B
     LEFT JOIN 
     country_club.Members M ON B.memid = M.memid
     LEFT JOIN
     country_club.Facilities F ON B.facid = F.facid
WHERE F.name LIKE '%tennis court%'
ORDER BY M.surname

/* question: not clear about if data is 
ordered by member's last name or first name; Ask the mentor */

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT F.name, B.starttime,
       CONCAT(M.firstname,' ', M.surname) AS 'member_names(first/last)',
       CASE WHEN M.memid = 0 THEN F.guestcost * B.slots 
       ELSE F.membercost * B.slots END AS 'cost'
FROM country_club.Bookings B
     LEFT JOIN 
     country_club.Members M ON B.memid = M.memid
     LEFT JOIN
     country_club.Facilities F ON B.facid = F.facid
WHERE B.starttime LIKE '%2012-09-14%'
      AND ((M.memid = 0 AND F.guestcost * B.slots >30)
      	   OR 
      	   (M.memid != 0 AND F.membercost * B.slots >30))
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT * 
FROM
(SELECT F.name, 
       CONCAT(M.firstname,' ', M.surname) AS 'member_names(first/last)',
       CASE WHEN M.memid = 0 THEN F.guestcost * B.slots 
       ELSE F.membercost * B.slots END AS 'cost'
FROM country_club.Bookings B
     LEFT JOIN 
     country_club.Members M ON B.memid = M.memid
     LEFT JOIN
     country_club.Facilities F ON B.facid = F.facid
WHERE B.starttime LIKE '%2012-09-14%') AS c
WHERE c.cost > 30
ORDER BY c.cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT c.name, SUM(c.cost) AS revenue
FROM
(SELECT F.name, 
       CASE WHEN M.memid = 0 THEN F.guestcost * B.slots 
       ELSE F.membercost * B.slots END AS 'cost'
FROM country_club.Bookings B
     LEFT JOIN 
     country_club.Members M ON B.memid = M.memid
     LEFT JOIN
     country_club.Facilities F ON B.facid = F.facid) AS c
GROUP BY c.name
HAVING revenue < 1000
ORDER BY revenue