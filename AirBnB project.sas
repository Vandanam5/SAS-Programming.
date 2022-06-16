LIBNAME PROJECT "C:\Users\vanda\OneDrive\Desktop\PROJECT DATASETS";

PROC IMPORT OUT= PROJECT.AirBnB 
            DATAFILE= "C:\Users\vanda\OneDrive\Desktop\PROJECT DATASETS\
AirBnB.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
	 guessingrows = max;
RUN;

* BROWSING THE DESCRIPTION PORTION ;
PROC CONTENTS DATA=PROJECT.AirBnB ;
RUN;

* BROWSING THE DATA PORTION ;
*FINDING HEAD OF DATA FOR 10 OBSERVATION;
proc print data= PROJECT.AirBnB (obs=10);
run;

*FINDING TAIL OF DATA FOR LAST 5 OBSERVATION;
proc print data= PROJECT.AirBnB(obs=38550  firstobs=38545);
run;

*TO FIND NUMBER OF UNIQUE/DISTNCT VALUES IN VARIABLES;
proc sql;
    select count(distinct host_id) as host_id
	,count(distinct hoSt_name) as hoSt_name
	,count (distinct price) as price
	,count (distinct last_review) as last_review
    ,count(distinct Property_Type) as Property_Type
	,count (distinct neighbourHood_group) as neighbourHood_group
	,count (distinct neighbourhood) as neighbourhood
	,count (distinct property_type) as property_type
	,count (distinct rooM_type) as rooM_type
    from PROJECT.AirBnB;
quit;

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


*CREATING A NEW COLUMN AS HOST_RATING BASED ON THE COLUMN REVIEW_SCORES_RATING TO 
MAKE 4 LEVELS OF DATA FOR EASY ANALYZATION, CHANGE THE DATATYPE OF THE NEW COLUMN TO CHARACHTER;
data PROJECT.AirBnB2;
set PROJECT.AirBnB1;
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
proc print data= PROJECT.AirBnB2 (OBS=25);* Viewing first 25 rows of the dataset;
run;


*RENAMING VARIABLE NEIGHBOURHOOD_GROUP TO LOCATION ;
DATA PROJECT.AirBnB3;
SET PROJECT.AirBnB2(RENAME=(NEIGHBOURHOOD_GROUP = LOCATION));
run;
proc print data= PROJECT.AirBnB3 (OBS=25);* Viewing first 25 rows of the dataset;
run;
*FINDING MISSING AND NONMISSING LEVELS;

Proc freq data=PROJECT.AirBnB3 nlevels;
   ods exclude onewayfreqs;
run;

proc mi data=PROJECT.AirBnB3 ;
ods select misspattern;
run;

*CHECKING FOR MISSING VALUES;
proc means data= PROJECT.AirBnB3 nmiss;
run;


*IDENTIFYING DUPLICATE VALUES IN THE DATA SET;
proc sort data=PROJECT.AirBnB3 ;
 by HOST_ID;
run; 
proc print data=PROJECT.AirBnB3; run;
data Norepeat Repeat;
			     set PROJECT.AirBnB3;
			       by HOST_ID;
			     if first.id_no then output Norepeat;
			     else output Repeat;
			  run; 
			  
			  Proc print data=Norepeat; run;
			  Proc print data=Repeat; run;


proc freq data= PROJECT.AirBnB3  ;
 tables HOST_ID/out=freqs;
run; 

*DROPPING DUPLICATED VALUES FROM DATASET;
PROC SORT DATA = PROJECT.AirBnB3 OUT = PROJECT.AirBnBdata NODUPKEY;
BY _ALL_;
RUN;
 

*ANALYSIS OF DATA AND VISUALIZATION

************************************************************************************************;
*UNIVARIATE ANALYSIS;
************************************************************************************************;
 *FOR ALL CONTINUOUS VARIABLES: summarization;

TITLE "DESCRIPTIVE ANALYSIS OF CONTINUOUS VARIABLES";
PROC MEANS DATA=PROJECT.AirBnBdata  N NMISS MIN Q1 MEDIAN  Q3 MAX qrange mean std cv clm maxdec=2  ;
VAR PRICE 
MINIMUM_NIGHTS 
REVIEW_SCORES_RATING 
NUMBER_OF_REVIEWS 
LAST_REVIEW 
LISTINGS_COUNT ;
RUN;
title;

title " Univarite analysis for AirBnB Price";
proc univariate data=PROJECT.AirBnBdata plot normal;
var PRICE;
run;
proc freq data=PROJECT.AirBnB;
    table room_type*neighbourhood_group / nopercent norow nocol;
run;

*NEW TRIALS;
*DISTRIBUTION OF DIFFERENT NEIGHBOURHOOD IN NYC ;

*SUMMARIZATION;
proc freq data= PROJECT.AirBnBdata;
 tables HOST_ID/out=freqs;
run; 
