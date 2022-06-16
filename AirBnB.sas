LIBNAME PROJECT "C:\Users\vanda\OneDrive\Desktop\PROJECT DATASETS";

*IMPORTING THE DATA SET;
PROC IMPORT OUT= PROJECT.AirBnB 
            DATAFILE= "C:\Users\vanda\OneDrive\Desktop\PROJECT DATASETS\
AirBnBdataset.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 guessingrows = max;
RUN;

* BROWSING THE DESCRIPTION PORTION ;
PROC CONTENTS DATA=PROJECT.AirBnB order=varnum ;
RUN;

* BROWSING THE DATA PORTION ;
*FINDING HEAD OF DATA FOR 10 OBSERVATION;
proc print data= PROJECT.AirBnB (obs=10);
run;

*FINDING TAIL OF DATA FOR LAST 5 OBSERVATION;
proc print data= PROJECT.AirBnB(obs=37788  firstobs=37779);
run;

*TO FIND NUMBER OF UNIQUE/DISTNCT VALUES IN VARIABLES;

Proc freq data=PROJECT.AirBnB nlevels;
   ods exclude onewayfreqs;
run;


* TO CHECK UNIQUE VALUE IN EACH GROUP;

proc freq data = PROJECT.AirBnB;
table neighbourhood_group room_type property_type neighbourhood /nopercent nocum;
run;

*CLEANING DATA ;

* DROPPING THE VARIABLE LATITUDE AND LONGITUDE AS THEY DONT ADD ANY MEANINGFUL INFORMATION ;
DATA PROJECT.AirBnB1(DROP = latitude longitude); 
SET PROJECT.AirBnB;
RUN;
PROC CONTENTS DATA=PROJECT.AirBnB1 order=varnum ;
RUN;

proc print data = PROJECT.AirBnB1 (OBS=10) ;run;

*CHANGING ALL THE VARIABLE NAMES TO UPPERCASE;

option VALIDVARNAME=UPCASE;
proc contents data= PROJECT.AirBnB1 out=PROJECT.AirBnBNY order = varnum; run;


*RENAMING VARIABLE NEIGHBOURHOOD_GROUP TO LOCATION ;
DATA PROJECT.AirBnB3;
SET PROJECT.AirBnB1(RENAME=(NEIGHBOURHOOD_GROUP = LOCATION));
run;
proc print data= PROJECT.AirBnB3 (OBS=5);* Viewing first 5 rows of the dataset;
run;

*CHECKING FOR MISSING VALUES OF NUMERICAL AND CATEGORICAL VARIABLES;
proc sql; 
    select nmiss(host_name) as HOST_NAME, nmiss(location) as LOCATION,nmiss(property_type) as PROPERTY_TYPE,
nmiss(room_type) as ROOM_TYPE
    from PROJECT.AirBnB3; 
quit;
proc means data= PROJECT.AirBnB3 nmiss;
run;


*DROPPING DUPLICATED VALUES FROM DATASET IF ANY;
PROC SORT DATA = PROJECT.AirBnB3 OUT = PROJECT.AirBnBdata NODUPKEY;
BY _ALL_;
RUN;
 

*DESCRIPTIVE ANALYSIS OF CONTINOUS VARIABLES;
TITLE "DESCRIPTIVE ANALYSIS OF CONTINUOUS VARIABLES";
PROC MEANS DATA=PROJECT.AirBnBdata  N NMISS MIN Q1 MEDIAN  Q3 MAX qrange mean std cv clm maxdec=2  ;
VAR 
MINIMUM_NIGHTS 
REVIEW_SCORES_RATING 
NUMBER_OF_REVIEWS 
LISTINGS_COUNT ;
RUN;
title;

*HANDLING OUTLIERS;
*HANDLING OUTLIERS IN PRICE BY CALCULATING UPPER FENCE AND LOWER FENCE;

DATA PROJECT.AirBnBT;
SET PROJECT.AirBnBDATA;
WHERE PRICE <400;
run;
*VISUALISATION USING BOX PLOT;
title "This is horizontal box plot for Number of Reviews";
Proc sgplot data=PROJECT.AirBnBT;
hbox price; 
run;

*FOR MINIMUM NIGHTS;
*DOING SEGMENTATION TO CREATE A CATEGORICAL COLUMN ;
data PROJECT.AirBnBNyc;
set PROJECT.AirBnBdata;
length MIN_NIGHT $50;
if MINIMUM_NIGHTS =1 then
do;
MIN_NIGHT = "One Night";
end;
else if MINIMUM_NIGHTS = 2 then
do;
MIN_NIGHT = "Two Nights";
end;
else if MINIMUM_NIGHTS = 3 then
do;
MIN_NIGHT = "Three Nights";
end;
else if MINIMUM_NIGHTS = 4 then
do;
MIN_NIGHT = "Four Nights";
end;
else if MINIMUM_NIGHTS = 5 then
do;
MIN_NIGHT = "Five Nights";
end;
else if MINIMUM_NIGHTS =6 then
do;
MIN_NIGHT = "Six Nights";
end;
else if MINIMUM_NIGHTS = 7 then
do;
MIN_NIGHT = "Seven Nights";
end;
else
do;
MIN_NIGHT = "Seven Nights or More";
end;
proc print data= PROJECT.AirBnBNyc(OBS=35);
run;

*QUESTION1.WHAT IS THE DISTRIBUTION OF DIFFERENT LOCATIONS OF AIRBNB'S IN NEWYORK?;
title "Distribution of AirBnB Listings by Locations in NYC";

PROC SGPLOT DATA= PROJECT.AirBnBNyc ;
 VBAR location / GROUP=location ;
RUN ;

proc freq data =PROJECT.AirBnBNyc ;
table Location /nopercent nocum;
run;

*QUESTION 2.WHAT ARE THE DIFFERENT ROOM TYPES/ACCOMODATION TYPES AVAILABLE IN THESE LOCATIONS ?;

title "Distribution Of Room Types Available In NYC Locations";
pattern1 color=VLIPB;
pattern2 color=PINK;
pattern3 color=YELLOW;

proc gchart data=PROJECT.AirBnBNyc;
 pie3d ROOM_TYPE /
 noheading percent=inside
 slice=outside value=inside
 coutline=black woutline=2;
run; 

*FREQUENCY TABLE;
proc freq data =PROJECT.AirBnBNyc ;
table ROOM_TYPE;
run;
title;

*QUESTION 3. WHAT IS THE DISTRIBUTION OF LISTING COUNT BETWEEN YEAR 2015 TO 2019?; 

Title "Distribution Of Listing counts Available Between the Year 2015 to 2019";

*SUMMARIZATION;
proc univariate data = PROJECT.AirBnBNyc;
var listings_count;
run;
*VISUAIZATION;
Proc sgplot data=PROJECT.AirBnBNyc;
histogram listings_count/ binwidth=30 binstart=0 datalabel=percent;
density listings_count;
density listings_count/ type = kernal;
run;
title;

*QUESTION 4.WHAT IS THE DISTRIBUTION OF PRICE RANGE OF AIRBNB ROOMS?; 

*Including the outliers;
Title "Distribution Of Price Range of AirBnB Rooms in NYC";
proc sgplot data=PROJECT.AirBnBNyc;
 hbox Price;
 run;

*Taking a subset of the price column with out the outliers;

proc sgplot data=PROJECT.AirBnBT;
 hbox Price;
 run;
proc univariate data = PROJECT.AirBnBT;
var price;
run;

*QUESTION 5. WHICH IS THE PREFFERED ROOM TYPE BY CUSTOMERS BASED ON LOCATION?;

PROC FREQ DATA = PROJECT.AirBnBNyc;
TABLE ROOM_TYPE*LOCATION/chisq;
run;

Title "Preffered Room type by Customers on Different Locations";
proc sgplot data =PROJECT.AirBnBNyc;
vbar location  / group = room_type groupdisplay = cluster;
run;
quit;
title;

*QUESTION 6. PRICE PER NIGHT BASED ON LOCATION AROUND NYC?;


Title "Price per night based on Different Locations";
proc sgplot data=PROJECT.AirBnBT;
   vbox PRICE / category=location group=room_type;
   xaxis label="Price per night";
   keylegend / title="Location";
run; 

proc glm data=PROJECT.AirBnBT;
class location;
model price = location;
means location / hovtest=levene(type=abs) welch;
run;

*QUESTION 6. HAS AIRBNB BECOME POPULAR OVER THE YEARS;
title "Popularity of AirBnB Over the years";
data project.year;
	set PROJECT.AirBnBNyc;
	my_year = year(last_review);    
run;
proc print data= project.year(obs = 10);
run;
title "Popularity of AirBnB Over the years";
proc sgplot data=project.year;
    scatter x = last_review  y = number_of_reviews; 
xaxis label= "Year";
yaxis label ="Reviews";
run;

PROC CORR DATA=project.year <PEARSON>;
    VAR MY_YEAR;
    WITH number_of_reviews;
RUN;

PROC CORR DATA=project.year  PLOTS=SCATTER(NVAR=all);
   VAR last_review number_of_reviews;
RUN;

*QUESTION 7. DISTRIBUTION OF AIRBNB BOOKING PER MONTH?;

title "Seasonal demand of airbnb";
data project.seasonal;
	set PROJECT.AirBnBNyc;
  month_year = intnx('month',last_review,0,'b');
  my_year = year(last_review);
run;
proc print data= project.seasonal(obs = 25);
format month_year  monname3.;
run;
*for year 2015;
DATA PROJECT.AirBnBmonth; 
   SET project.seasonal;
   KEEP MONTH_YEAR MY_YEAR number_of_reviews ;
   where MY_YEAR = 2015;
RUN;
proc print data = PROJECT.AirBnBmonth (obs=25);
format month_year  monname3.;
run;
proc sql;
create table myseason as
select put (month_year,monname3.)as month,
sum(number_of_reviews) as review_sum
from PROJECT.AirBnBmonth
group by month_year;
run;
 data PROJECT.AirBnBmyseason;
 set myseason;
 run;
 proc print data =  PROJECT.AirBnBmyseason;
 run;
proc sgplot data= PROJECT.AirBnBmyseason;
    series x= month y=review_sum;
     xaxis label= "Months in 2015";
yaxis label ="Reviews";
run;
*for year 2016;
DATA PROJECT.AirBnBmonth; 
   SET project.seasonal;
   KEEP MONTH_YEAR MY_YEAR number_of_reviews ;
   where MY_YEAR = 2016;
RUN;
proc print data = PROJECT.AirBnBmonth (obs=25);
format month_year  monname3.;
run;
proc sql;
create table myseason as
select put (month_year,monname3.)as month,
sum(number_of_reviews) as review_sum
from PROJECT.AirBnBmonth
group by month_year;
run;
 data PROJECT.AirBnBmyseason;
 set myseason;
 run;
 proc print data =  PROJECT.AirBnBmyseason;
 run;
proc sgplot data= PROJECT.AirBnBmyseason;
    series x= month y=review_sum;
     xaxis label= "Months in 2016";
yaxis label ="Reviews";
run;
*for year 2017;
DATA PROJECT.AirBnBmonth; 
   SET project.seasonal;
   KEEP MONTH_YEAR MY_YEAR number_of_reviews ;
   where MY_YEAR = 2017;
RUN;
proc print data = PROJECT.AirBnBmonth (obs=25);
format month_year  monname3.;
run;
proc sql;
create table myseason as
select put (month_year,monname3.)as month,
sum(number_of_reviews) as review_sum
from PROJECT.AirBnBmonth
group by month_year;
run;
 data PROJECT.AirBnBmyseason;
 set myseason;
 run;
 proc print data =  PROJECT.AirBnBmyseason;
 run;
proc sgplot data= PROJECT.AirBnBmyseason;
    series x= month y=review_sum;
     xaxis label= "Months in 2017";
yaxis label ="Reviews";
run;
*for year 2018;
DATA PROJECT.AirBnBmonth; 
   SET project.seasonal;
   KEEP MONTH_YEAR MY_YEAR number_of_reviews ;
   where MY_YEAR = 2018;
RUN;
proc print data = PROJECT.AirBnBmonth (obs=25);
format month_year  monname3.;
run;
proc sql;
create table myseason as
select put (month_year,monname3.)as month,
sum(number_of_reviews) as review_sum
from PROJECT.AirBnBmonth
group by month_year;
run;
 data PROJECT.AirBnBmyseason;
 set myseason;
 run;
 proc print data =  PROJECT.AirBnBmyseason;
 run;
proc sgplot data= PROJECT.AirBnBmyseason;
    series x= month y=review_sum;
     xaxis label= "Months in 2018";
yaxis label ="Reviews";
run;
*QUESTION 8. IS THERE RELATION BETWEEN HOST RATING AND ROOM TYPE?

*CREATING A NEW COLUMN AS HOST_RATING BASED ON THE COLUMN REVIEW_SCORES_RATING TO 
MAKE 4 LEVELS OF DATA FOR EASY ANALYZATION, CHANGE THE DATATYPE OF THE NEW COLUMN TO CHARACHTER;
data PROJECT.AirBnBrating;
set PROJECT.AirBnBT;
length HOST_RATING $20;
if REVIEW_SCORES_RATING <=3 then
do;
HOST_RATING = "Poor";
end;
else if 4<=REVIEW_SCORES_RATING <=6 then
do;
HOST_RATING = "Moderate";
end;
else if 7<=REVIEW_SCORES_RATING<=8 then
do;
HOST_RATING = "Good";
end;
else
do;
HOST_RATING = "Excellent";
end;
proc print data= PROJECT.AirBnBrating (OBS=10);* Viewing first 25 rows of the dataset;
run;

*visualization;
Title "Host ratings based on Room type";
proc sgplot data =PROJECT.AirBnBrating;
vbar room_type/ group = host_rating groupdisplay = stack;
run;
quit;

*contingency table and chisquare test;
PROC FREQ DATA =PROJECT.AirBnBrating;
TABLE room_type*host_rating/chisq;
run;

*QUESTION 9. TOP 10 HOST BASED ON NUMBER OF REVIEWS ?;


DATA PROJECT.AirBnBTop10; 
   SET PROJECT.AirBnBNyc;
   KEEP Host_Name Number_of_reviews;
RUN;

proc sort data = PROJECT.AirBnBTop10 out=PROJECT.AirBnBTop10out;
by  Number_of_reviews;
run;
proc print data= PROJECT.AirBnBTop10out (obs=37788  firstobs=37777);
run;
Title "Top 10 AirBnB Host with Maximum Reviews";
data project.airbnbtopoutt;
set PROJECT.AirBnBTop10out;
where Number_of_reviews >= 480;
run;
proc print data= PROJECT.AirBnBTopoutt;
run;
proc sort data =PROJECT.AirBnBTopoutt out= project.AirBnBsorted;
by descending Number_of_reviews;
run;
proc print data= project.AirBnBsorted;
run;

*VISUALIZATION BARCHART;
title "Top 10 AirBnB Host with Maximum Reviews";
proc sgplot data=project.AirBnBsorted noborder;
  vbar Host_Name / response=Number_of_reviews stat=mean barwidth=0.8 datalabel group=Host_Name colorresponse=Number_of_reviews;
  xaxis display=(nolabel noline noticks);
  yaxis display=(noline) grid;
  keylegend / noborder;
  format Number_of_reviews 8.0;
run;
title;

*QUESTION 10.VARIATION IN AIRBNB PRICE OVER THE YEARS ?;

title  "Variation in AirBnB price over the Years";
proc sgplot data=PROJECT.AirBnBT;
    scatter x = last_review y = price/colorresponse=price; 
xaxis label= "Year( 2015 -2019 )";
yaxis label ="Price";
run;
PROC CORR DATA=PROJECT.AirBnBT  PLOTS=SCATTER(NVAR=all);
   VAR last_review price;
RUN;





















