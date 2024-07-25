#delimit ;

cd "C:\Users\mmacis1\Dropbox\ARC_LMS\ARC_OLD_dataprep\wtbb\aej\published_paper\ReplicationMaterials" ;

capture log close ;
log using dowtbb_replicate.log, replace text ;

set more 1 ;
clear ;
clear matrix ;
clear mata ;
set mem 400m ;
set matsize 4000 ;
use wtbb_publicdata.dta ;

/* create vars */ ;

tab year, gen (dumyear) ;
tab month, gen (dummonth) ;
tab weekday, gen (dumday) ;
tab zipid, gen(dumzip) ;

gen temp=1 if temperature<=36 ;
replace temp=2 if temperature>36 & temperature<=53 ;
replace temp=3 if temperature>53 & temperature<=68 ;
replace temp=4 if temperature>68 & temperature<=75 ;
replace temp=5 if temperature>75 ;
tab temp, gen (dumtemp) ;

gen open_fl=open*flyer ;
gen incent_open=incentive*open ;
gen incent_fl=incentive*flyer ;
gen incent_open_fl=incentive*open*flyer ;
gen incentcostopenfl=incentcost*open_fl ;
gen incentcostsqopenfl=incentcostsq*open_fl ;
 
/* Table 1: Summary statistics - full sample */ ;

sum presenting collected sharedef 
    open flyer open_fl length 
	incentive 
	temperature freeze rain intensity snow rainyday snowyday, d;

/* Drop drives in bottom and top 1 percent of presenting*/ ;
sum presenting, d ;
drop if presenting<=6 ;
drop if presenting>=129 ;

/* Table 1: Summary statistics - Dropping outliers */ ;
sum presenting collected sharedef 
    open flyer open_fl length 
	incentive 
	temperature freeze rain intensity snow rainyday snowyday, d ;

/* Web Appendix Table 1: Summary statistics - Dropping outliers & non-missing rain intensity */ ;
sum presenting collected sharedef 
    open flyer open_fl length 
	incentive 
	temperature freeze rain intensity snow rainyday snowyday if intensity~=., d;

/* Table 2: Incentives at ARC Blood Drives */ ;
sum dumitem* if incentive==1 ;
sum dumitem* if incentive==1 & open==1 ;
sum dumitem* if incentive==1 & open==1 & flyer==1 ;
 
/* Web Appendix Table 2: Drive Host Types and Incentives */ ;
table type, c(n presenting mean presenting mean incentive) ;

/* Table 3: Drive hosts and incentives */ ;
bysort hostid: gen ndrives=_N ;
bysort hostid: egen meanincentive=mean(incentive) ;
gen s=0 ;
bysort hostid: replace s=1 if _n==1 ;
* all drives ;
tab s ;
sum presenting ;
*hostids with one drive only ;
gen onedrive=(ndrives==1) ;
tab s if ndrives==1 ;
tab onedrive if s==1 ;
sum presenting if ndrives==1 ;
sum presenting if ndrives==1 & meanincentive>0 ;
*hostids with at least two drives  ;
tab s if ndrives>=2 ;
sum presenting if ndrives>=2 ;
tab s if ndrives>=2 & meanincentive==0 ;
tab s if ndrives>=2 & meanincentive==1 ;
tab s if ndrives>=2 & meanincentive>0 & meanincentive<1 ;
sum presenting if ndrives>=2 & meanincentive==0 ;
sum presenting if ndrives>=2 & meanincentive==1 ;
sum presenting if ndrives>=2 & meanincentive>0 & meanincentive<1 ;
sum presenting if ndrives>=2 & meanincentive>0 & meanincentive<1 & incentive==0 ;
sum presenting if ndrives>=2 & meanincentive>0 & meanincentive<1 & incentive==1 ;

/* Table 4: Statistics on neighboring drives */ ;
** See below, right before the Displacement regressions-main ** ;

/* LOCAL EFFECTS ANALYSIS */ ;

/* Table 5a: Local effects of incentives on the number of donors presenting at a drive */ ;

xi: reg	presenting incentive
		, cluster(hostid);
	outreg2 using regressions-main.xls, bdec(2) replace;

/* ;
xi: reg presenting incentive if intensity~=., cluster(hostid);
	outreg2 using regressions-main.xls, bdec(2) replace;
*/ ;

xi: reg		presenting 
			incentive
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week dumzip*
			, cluster(hostid);
		outreg2 using regressions-main.xls, bdec(2) append;

/* For the small fraction (7 percent) of hosts who ran both open and closed drives, 
we include specific fixed effects for the open and for the closed drives. These groups
are defined here */ ;

egen hostid=group(hostid_0 open) ;

iis hostid ;

xi: xtreg	presenting 
			incentive
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(2) append;

xi: xtreg	presenting 
			incentive incent_open 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(2) append;

xi: xtreg	presenting 
			incentive incent_fl 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(2) append;

xi:	xtreg	presenting 
			incentive incent_open_fl open_fl 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(2) append;
	
/* Table 5b: Local effects of incentives on the number of units of blood collected and the share of donors deferred */ ;

xi:	xtreg	collected 
			incentive   
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(2) append;

xi: xtreg	collected 
			incentive incent_open 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(2) append;

xi: xtreg	collected 
			incentive incent_fl
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(2) append;

xi: xtreg	collected 
			incentive incent_open_fl open_fl
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(2) append;

xi: xtreg	sharedef 
			incentive   
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(3) append;

xi:	xtreg	sharedef 
			incentive incent_open  
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(3) append;

xi: xtreg	sharedef 
			incentive incent_fl 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(3) append;

xi: xtreg	sharedef 
			incentive incent_open_fl open_fl
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main.xls, bdec(3) append;

/* Table 6: Effects of incentive costs regressions */ ;
xi:	xtreg	presenting 
			incentive incentcost incentcostsq
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(6) replace;  

xi: xtreg	collected 
			incentive incentcost incentcostsq 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(6) append;  

xi: xtreg	sharedef 
			incentive incentcost incentcostsq 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(6) append;  

xi: xtreg	presenting 
			incentive open_fl incentcost incentcostsq incentcostopenfl incentcostsqopenfl
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	collected 
			incentive open_fl incentcost incentcostsq incentcostopenfl incentcostsqopenfl
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	sharedef 
			incentive open_fl incentcost incentcostsq incentcostopenfl incentcostsqopenfl
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(3) append;  

/* Figure 2: Estimated Effects of Incentive Costs 
The figure is created using the coefficients from Table 6
See the excel file "LMS_AEJPol_2011_0037_Figure2" */ ;

/* Web Appendix Table 3: Effects of incentive costs regressions
   Same as Table 6 but  dropping if missingcost = 1          */ ;
	
	
xi:	xtreg	presenting 
			incentive incentcost incentcostsq
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if missingcost~=1
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	collected 
			incentive incentcost incentcostsq 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if missingcost~=1
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	sharedef 
			incentive incentcost incentcostsq 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if missingcost~=1
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(3) append;  

xi: xtreg	presenting 
			incentive open_fl incentcost incentcostsq incentcostopenfl incentcostsqopenfl
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if missingcost~=1
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	collected 
			incentive open_fl incentcost incentcostsq incentcostopenfl incentcostsqopenfl
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if missingcost~=1
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	sharedef 
			incentive open_fl incentcost incentcostsq incentcostopenfl incentcostsqopenfl
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if missingcost~=1
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(3) append;  


/* Web Appendix Table 4: Effects of incentive costs regressions
Controlling for absolute and/or relative frequency incentive items */ ;

forvalues i=1(1)15 {  ;
bysort hostid: egen n`i'=sum(dumitem`i') ; 
} ;

gen incentfreq=0 ;
forvalues i=1(1)15 {  ;
replace incentfreq=n`i' if dumitem`i'==1 ;
} ;

gen incentfreq2=incentfreq^2 ;

drop n1-n15 ;

forvalues i=1(1)15 {  ;
bysort hostid: egen xn`i'=mean(dumitem`i') if incentive==1 ; 
bysort hostid: egen n`i'=max(xn`i'); 
} ;

gen incentperc=0 ;
forvalues i=1(1)15 {  ;
replace incentperc=n`i' if dumitem`i'==1 ;
} ;

replace incentperc=incentperc*100 ;
gen incentperc2=incentperc^2 ;

drop xn1-xn15 ;
drop n1-n15 ;

xi: xtreg	presenting 
			incentive incentcost incentcostsq incentfreq incentfreq2
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	collected 
			incentive incentcost incentcostsq incentfreq incentfreq2
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	sharedef 
			incentive incentcost incentcostsq incentfreq incentfreq2
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(3) append;  

xi: xtreg	presenting 
			incentive incentcost incentcostsq incentperc incentperc2
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	collected 
			incentive incentcost incentcostsq incentperc incentperc2
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg 	sharedef 
			incentive incentcost incentcostsq incentperc incentperc2
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(3) append;  


/* Web Appendix Table 5: Effect of incentive on drive length and open/closed status */ ;

#delimit ;

iis hostid_0 ;

sum length open if incentive==0 ;

xi: xtreg	length 
			incentive
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid_0);
		outreg2 using regressions-checkhost.xls, bdec(2) replace;

xi: xtreg	open 
			incentive
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid_0);
		outreg2 using regressions-checkhost.xls, bdec(3) append;

		
/* Web Appendix Table 6: Effects of incentive costs regressions
   at "not engaged" hosts                                  */ ;

iis hostid ;   
   
gen xsomehostitem=(dumitem14==1) ;
bysort hostid: egen active=max(xsomehostitem) ;
   
xi:	xtreg	presenting 
			incentive
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if active==0
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	sharedef 
			incentive 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if active==0
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(3) append;  

xi:	xtreg	presenting 
			incentive incentcost incentcostsq
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			if active==0
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	sharedef 
			incentive incentcost incentcostsq 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			if active==0
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(3) append;  

xi: xtreg	presenting 
			incentive open_fl incentcost incentcostsq incentcostopenfl incentcostsqopenfl
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			if active==0
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(2) append;  

xi: xtreg	sharedef 
			incentive open_fl incentcost incentcostsq incentcostopenfl incentcostsqopenfl
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			if active==0
			, fe cluster(hostid);
		outreg2 using regressions-main-cost.xls, bdec(3) append;  


/* Table 7: Effects of specific incentive items */ ;

xi: xtreg	presenting 
			dumitem1-dumitem15 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main-specific.xls, bdec(2) replace;  

		lincom dumitem5-dumitem1 ;
		lincom dumitem5-dumitem13 ;
		lincom dumitem1-dumitem13 ;

xi: xtreg	sharedef 
			dumitem1-dumitem15 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-main-specific.xls, bdec(3) append;  

		lincom dumitem5-dumitem1 ;
		lincom dumitem5-dumitem13 ;
		lincom dumitem1-dumitem13 ;

xi: xtreg	presenting 
			dumitem1-dumitem15 dumattr1-dumattr17 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if (open==1 & flyer==1)
			, fe cluster(hostid);
		outreg2 using regressions-main-specific.xls, bdec(2) append;  

		lincom dumitem5-dumitem1 ;
		lincom dumitem5-dumitem13 ;
		lincom dumitem1-dumitem13 ;

xi: xtreg	sharedef 
			dumitem1-dumitem15 dumattr1-dumattr17 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if (open==1 & flyer==1)
			, fe cluster(hostid);
		outreg2 using regressions-main-specific.xls, bdec(3) append;  

		lincom dumitem5-dumitem1 ;
		lincom dumitem5-dumitem13 ;
		lincom dumitem1-dumitem13 ;

/* Web Appendix Table 7: Effect of incentives at previous drive */ ;

sort hostid date;
by hostid: gen incprev=incentive[_n-1];
by hostid: gen costprev=incentcost[_n-1];
replace costprev=. if incprev==.;
gen costprevsq=costprev^2;
gen noinc=(incentive==0);
gen noinc_incprev=noinc*incprev;

xi: xtreg	presenting 
			incentive incprev 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-previous.xls, bdec(2) replace;

xi: xtreg	presenting 
			incentive incprev noinc_incprev
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			, fe cluster(hostid);
		outreg2 using regressions-previous.xls, bdec(2) append;
	
xi: xtreg	presenting 
			incentive incentcost incentcostsq incprev costprev costprevsq
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			, fe cluster(hostid);
		outreg2 using regressions-previous.xls, bdec(2) append;

xi: xtreg	presenting 
			incentive incprev 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if (open==1 & flyer==1)
			, fe cluster(hostid);
		outreg2 using regressions-previous.xls, bdec(2) append;

xi: xtreg	presenting 
			incentive incprev noinc_incprev
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			if (open==1 & flyer==1)
			, fe cluster(hostid);
		outreg2 using regressions-previous.xls, bdec(2) append;
	
xi: xtreg	presenting 
			incentive incentcost incentcostsq incprev costprev costprevsq
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
			dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost
			if (open==1 & flyer==1)
			, fe cluster(hostid);
		outreg2 using regressions-previous.xls, bdec(2) append;

		
/* DISPLACEMENT ANALYSIS */ ;
 
/* drop the first 56 dates and the last 30 dates */
drop if date<=16973 ;
drop if date>=17784 ;

/* Table 4: Statistics on neighboring drives */ ;

sum all02 all24 all410 inc02 inc24 inc410 ;
gen ni02=all02-inc02 ;
gen ni24=all24-inc24 ;
gen ni410=all410-inc410 ;
sum all02 all24 all410 ni02 ni24 ni410 if incentive==1 ;

#delimit ;

 /* Table 11: Displacement effects on number of donors presenting */ ;

xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        all02 all24 all410
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost , fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) replace;  

xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        inc02 inc24 inc410
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost , fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) append;  

xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        highstcost02 highstcost24 highstcost410
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost , fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) append;  
	
gen all02_inc = all02*incentive ;
gen all24_inc = all24*incentive ;
gen all410_inc = all410*incentive ;

gen inc02_inc = inc02*incentive ;
gen inc24_inc = inc24*incentive ;
gen inc410_inc = inc410*incentive ;

gen highstcost02_inc = highstcost02*incentive ;
gen highstcost24_inc = highstcost24*incentive ;
gen highstcost410_inc = highstcost410*incentive ;

xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        all02 all02_inc all24 all24_inc all410 all410_inc
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost , fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) append;  

xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        inc02 inc02_inc inc24 inc24_inc inc410 inc410_inc
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost , fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) append;  
	
xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        highstcost02 highstcost02_inc highstcost24 highstcost24_inc highstcost410 highstcost410_inc
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost , fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) append;  

xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        all02 all02_inc inc02 inc02_inc 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost , fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) append;  
	
xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        all02 all02_inc inc02 inc02_inc highstcost02 highstcost02_inc 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost , fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) append;  

		
/* Web Appendix Table 8: Displacement effects by type of drive */ ;

xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        all02 all02_inc inc02 inc02_inc highstcost02 highstcost02_inc 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost 
			, fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) append;  

xi: xtreg	sharedef 
			incentive incentcost incentcostsq 
	        all02 all02_inc inc02 inc02_inc highstcost02 highstcost02_inc 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost 
			, fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(3) append;  

xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        all02 all02_inc inc02 inc02_inc highstcost02 highstcost02_inc 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost 
			if open==0
			, fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) append;  

xi: xtreg	sharedef 
			incentive incentcost incentcostsq 
	        all02 all02_inc inc02 inc02_inc highstcost02 highstcost02_inc 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost 
			if open==0
			, fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(3) append;  

xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        all02 all02_inc inc02 inc02_inc highstcost02 highstcost02_inc 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost 
			if open==1
			, fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) append;  

xi: xtreg	sharedef 
			incentive incentcost incentcostsq 
	        all02 all02_inc inc02 inc02_inc highstcost02 highstcost02_inc 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost 
			if open==1
			, fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(3) append;  

xi: xtreg	presenting 
			incentive incentcost incentcostsq 
	        all02 all02_inc inc02 inc02_inc highstcost02 highstcost02_inc 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost 
			if open==1 & flyer==1
			, fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(2) append;  

xi: xtreg	sharedef 
			incentive incentcost incentcostsq 
	        all02 all02_inc inc02 inc02_inc highstcost02 highstcost02_inc 
			dumtemp* length rain rain2 intensity intensity2 snow snow2 
            dumattr* dumyear* dummonth* dumday* i.repid*i.week
			missingcost 
			if open==1 & flyer==1
			, fe cluster(hostid);
		outreg2 using regressions-subs.xls, bdec(3) append;  
		

stop;
stop;
stop;
stop;
		
/* ANALYSIS OD FIELD-EXPERIMENTAL DATA */ ;

use "C:\Users\mmacis\Documents\My Dropbox\LMS\wtbb\data_and_dofiles\output\wtbbexperdata.dta", clear ;

gen TR_ADVERT=(TR==1 & ADVERT==1) ;
gen TR_SURPR=(TR==1 & ADVERT==0) ;

gen EXP_TR_ADVERT=EXP*TR_ADVERT ;
gen EXP_TR_SURPR=EXP*TR_SURPR ;

gen TR5ADVERT=(TR5==1 & TR_ADVERT==1) ;
gen TR10ADVERT=(TR10==1 & TR_ADVERT==1) ;
gen TR15ADVERT=(TR15==1 & TR_ADVERT==1) ;

gen EXP_TR5ADVERT=EXP*TR5ADVERT ;
gen EXP_TR10ADVERT=EXP*TR10ADVERT ;
gen EXP_TR15ADVERT=EXP*TR15ADVERT ;

/* Table 8: Pre-treatment characteristics of the field experiment sites */ ;

sort wave hostid ;

gen treattype=0 ;
replace treattype=1 if TR_ADVERT==1 ;
replace treattype=2 if TR_SURPR==1 ;

bysort treattype: sum presenting collected sharedef if EXP==0 ;
bysort treattype: sum ndrivespast fracmatpast length if EXP==0 ;

/* T-tests for differences in pre-intervention characteristics */ ;

ttest presenting if (treattype==0|treattype==2) & EXP==0, by(treattype) ;
ttest collected if (treattype==0|treattype==2) & EXP==0, by(treattype) ;
ttest sharedef if (treattype==0|treattype==2) & EXP==0, by(treattype) ;
ttest length if (treattype==0|treattype==2) & EXP==0, by(treattype) ;
ttest ndrivespast if (treattype==0|treattype==2) & EXP==0, by(treattype) ;
ttest fracmatpast if (treattype==0|treattype==2) & EXP==0, by(treattype) ;

ttest presenting if (treattype==1|treattype==2) & EXP==0, by(treattype) ;
ttest collected if (treattype==1|treattype==2) & EXP==0, by(treattype) ;
ttest sharedef if (treattype==1|treattype==2) & EXP==0, by(treattype) ;
ttest length if (treattype==1|treattype==2) & EXP==0, by(treattype) ;
ttest ndrivespast if (treattype==1|treattype==2) & EXP==0, by(treattype) ;
ttest fracmatpast if (treattype==1|treattype==2) & EXP==0, by(treattype) ;

/* Table 9: Differences-in-differences results from the field experiment  */ ;

/* we need to drop one of the sites because at one advertised treatment
drive, unforeseen contingencies did not allow us to apply the experimental
protocol */ ;

drop if hostid==3  ;
bysort treattype EXP: sum presenting collected sharedef ;
bysort EXP: sum presenting collected sharedef if TR5ADVERT==1 ;
bysort EXP: sum presenting collected sharedef if TR10ADVERT==1 ;
bysort EXP: sum presenting collected sharedef if TR15ADVERT==1 ;

/* Table 10: Differences-in-differences results from the field experiment  */ ;
/* Fixed effects are defined at the host-wave level
because some hosts have been used in more than one wave
Note: when a host was used in two waves, it was always used as a control
first, and as a treatment site later */  ;

egen hostwave=group(hostid wave) ;
iis hostwave ;

xi: xtreg	presenting 
			EXP EXP_TR_ADVERT EXP_TR_SURPR 
			length
			, fe cluster(hostwave) ;
		outreg2 using wtbbexper.xls, replace bdec(2) ;
lincom EXP_TR_ADVERT-EXP_TR_SURPR ;

xi: xtreg	sharedef 
			EXP EXP_TR_ADVERT EXP_TR_SURPR 
			length
			, fe cluster(hostwave) ;
		outreg2 using wtbbexper.xls, append bdec(3) ;
		lincom EXP_TR_ADVERT-EXP_TR_SURPR ;

xi: xtreg	presenting 
			EXP EXP_TR5ADVERT EXP_TR10ADVERT EXP_TR15ADVERT EXP_TR_SURPR 
			length
			, fe cluster(hostwave) ;
		outreg2 using wtbbexper.xls, append bdec(2) ;
		lincom EXP_TR10ADVERT-EXP_TR5ADVERT ;
		lincom EXP_TR15ADVERT-EXP_TR10ADVERT ;
		lincom EXP_TR15ADVERT-EXP_TR5ADVERT ;

xi: xtreg	sharedef 
			EXP EXP_TR5ADVERT EXP_TR10ADVERT EXP_TR15ADVERT EXP_TR_SURPR 
			length
			, fe cluster(hostwave) ;
		outreg2 using wtbbexper.xls, append bdec(3) ;
		lincom EXP_TR10ADVERT-EXP_TR5ADVERT ;
		lincom EXP_TR15ADVERT-EXP_TR10ADVERT ;
		lincom EXP_TR15ADVERT-EXP_TR5ADVERT ;

gen VALUE=0 ;
replace VALUE=5 if TR5==1 ;
replace VALUE=10 if TR10==1 ;
replace VALUE=15 if TR15==1 ;

gen EXP_VALUE_ADVERT=VALUE*EXP*TR_ADVERT ;
gen EXP_VALUE_SURPR=VALUE*EXP*TR_SURPR ;

xi: xtreg	presenting EXP EXP_VALUE_ADVERT EXP_VALUE_SURPR length, fe nonest cluster(hostwave) ;
		outreg2 using wtbbexper.xls, append bdec(2) ;

xi: xtreg	sharedef EXP EXP_VALUE_ADVERT EXP_VALUE_SURPR length, fe nonest cluster(hostwave) ;
		outreg2 using wtbbexper.xls, append bdec(3) ;

log close ;

*****************************************************************************************
*****************************************************************************************
/* Figure 3: Simulated Random Assignment of Incentives to Host-Locations  ;

% Simulations (30/03/2010)

% ************************************************************************
% This first part is simply to read in a textfile called 'sponsors.txt'


% Note - I got Excel to sort by the number of events hosted. 

b=[];       	% Initialised a null matrix to fill with data later.
fid = fopen('sponsors.txt');    % Read in the file (into Binary format?)

while 1                         % Loop to read each line of text
    tline = fgetl(fid);         % fgetl() reads each line
    if ~ischar(tline),   break,   end
    a = str2num(tline);         % This converts a string 
    b = [b;a];                  % Fill the matrix!
end

% b is a (9792 x 3) matrix with the following column headers:
% {'melARCid','promocost','spobs';}

% Respectively:
% Unique sponsor ID, promo cost during each event, no. of events for each
% sponsor.

fclose(fid);                    % Close the read.
% ************************************************************************

% This table gives the frequency with which sponsors host events. The
% column headings are as follows:
 
% bins	Frequencies	Uniq. Spon	U.S. Percent	U.S. Cumul

% Respectively: Frequency of hosting, Sponsor Freq., No. of unique
% sponsors, Percentage, Cumulative Percentage.
sponsorfreq = [2	198	99	9.30	9.30
3	321	107	10.05	19.34
4	532	133	12.49	31.83
5	535	107	10.05	41.88
6	408	68	6.38	48.26
7	315	45	4.23	52.49
8	432	54	5.07	57.56
9	351	39	3.66	61.22
10	580	58	5.45	66.67
11	275	25	2.35	69.01
12	420	35	3.29	72.30
13	403	31	2.91	75.21
14	924	66	6.20	81.41
15	1140	76	7.14	88.54
16	544	34	3.19	91.74
17	238	14	1.31	93.05
18	144	8	0.75	93.80
19	95	5	0.47	94.27
20	80	4	0.38	94.65
21	84	4	0.38	95.02
22	44	2	0.19	95.21
23	69	3	0.28	95.49
24	120	5	0.47	95.96
25	75	3	0.28	96.24
26	130	5	0.47	96.71
27	54	2	0.19	96.90
28	56	2	0.19	97.09
29	145	5	0.47	97.56
30	150	5	0.47	98.03
31	62	2	0.19	98.22
32	64	2	0.19	98.40
33	66	2	0.19	98.59
34	34	1	0.09	98.69
36	144	4	0.38	99.06
38	38	1	0.09	99.15
40	40	1	0.09	99.25
42	84	2	0.19	99.44
45	90	2	0.19	99.62
48	48	1	0.09	99.72
58	58	1	0.09	99.81
75	75	1	0.09	99.91
127	127	1	0.09	100.00];


% The following table gives the frequency with which promotions with a
% certain value occur. The column headings are as follows:

% bins	P. Freq	P. Percent	P.Cumul

% Respectively: Promotion cost, Frequency, Percent, Cumulative Percentage.

promofreqraw = [0	6669	68.11	68.11
1	143	1.46	69.57
1.42	40	0.41	69.98
1.5	31	0.32	70.29
1.78	119	1.22	71.51
1.94	58	0.59	72.10
2.5	40	0.41	72.51
2.78	1	0.01	72.52
2.95	1954	19.96	92.47
3.75	379	3.87	96.34
3.95	35	0.36	96.70
4.58	91	0.93	97.63
4.75	1	0.01	97.64
4.89	1	0.01	97.65
6.33	45	0.46	98.11
6.67	93	0.95	99.06
6.7	1	0.01	99.07
9.37	57	0.58	99.65
9.5	34	0.35	100.00];


% All bins with a frequency of 1 have been collapsed into the closest bin.
promofreq = [0	6669	68.11	68.11
1	143	1.46	69.57
1.42	40	0.41	69.98
1.5	31	0.32	70.29
1.78	119	1.22	71.51
1.94	58	0.59	72.10
2.5	40	0.41	72.51
2.95	1955	19.97	92.47
3.75	379	3.87	96.34
3.95	35	0.36	96.70
4.58	93	0.95	97.65
6.33	45	0.46	98.11
6.67	94	0.96	99.07
9.37	57	0.58	99.65
9.5	34	0.35	100.00];

% ************************************************************************
% This section obtains information on each UNIQUE sponsor from the raw
% data.
sponinfo = [];
% sponinfo column headings are as follows:
% melARCid, Numeric ID, No. of Events, Total Promo Cost, Average Promo Cost

i = 1;
myID = 0;

while(i <= length(b))
    tempmelARCid = b(i,1);
    myID = myID + 1;
    tempeventfreq = b(i,3);
    temptotalcost = 0;
    tempmeanpromo= 0;
    j = 1;
    while(j <= tempeventfreq)
        temptotalcost = temptotalcost + b(i,2);
        j = j+1;
        i = i+1
    end
    
    tempmeanpromo = temptotalcost/tempeventfreq;
    sponinfo = [sponinfo;tempmelARCid myID tempeventfreq temptotalcost tempmeanpromo];
end

% Sort in ascending order of average promo cost
sponinfo = sortrows(sponinfo, [5,3]);    
size(sponinfo)

% Getting 10ths of the ACTUAL data to facilitate comparison with simulated
% data.

actualpromomeans = sponinfo(:,5);
actualtenths = zeros(100,1);

% Creating a (100,1) vector of positions: 10.65, 21.30, etc
quartiles = [10.65:10.65:1065]'

% Make this vector a (100x3) matrix where the second column rounds the
% first one down and the third rounds it up. Thus I have the appropriate
% positions to average over.
quartiles = [quartiles floor(quartiles) ceil(quartiles)]

size(quartiles)

x = 0;
while(x < length(quartiles))
    x = x + 1;
    
    % The difference between the actual value and the rounded down value
    % gives me the weight for the lower value. (1 - difference) gives me
    % the weight for the upper value. For example: 10.65 - 10 = 0.65,
    % making the average 0.65*10th position + (1-0.65)*11th position.
    diff = quartiles(x,1) - quartiles(x,2);
    lower = quartiles(x,2);
    upper = quartiles(x,3);
    
    actualtenths(x,:) = diff*actualpromomeans(lower) + (1-diff)*actualpromomeans(upper);
    
end
actualtenths

size(actualtenths)

% ************************************************************************
% SIMULATING
% ************************************************************************

% Creating urns to draw from:

% To simulate, I need two 'urns' to draw from (without replacement). One 
% urn for the number of drives a sponsor hosts and the other for the 
% promocost per drive. 

% Urn 1:
% Urn for the number of drives. This should contain 1065 entries, ranging
% from a minimum of two to 127 drives. 

urndrives = zeros(1065,1);

urnhowmanywithxdrives = 0;
urn1fullness = 0;
k = 0;
while(k < length(sponsorfreq))
    k = k + 1;
    
    urnhowmanywithxdrives = sponsorfreq(k,3);
    
    
    l = 0;
    while(l < urnhowmanywithxdrives)
        l = l + 1;
        urndrives(urn1fullness + l,1) = sponsorfreq(k,1);                 
    end
    
    urn1fullness = urn1fullness + urnhowmanywithxdrives;
end


% Urn 2:
% Urn for the promocosts. This should contain 9792 entries, ranging
% from a minimum of two to 127 drives. 

% Note - it is important for me to reduce the 9792 entries for the 1065
% 0-entries that each sponsor has one of by default. This means that each
% of the 1065 sponsors is assigned at least one 0-entry by default.

adjpromofreq = promofreq;
adjpromofreq(1,2)= adjpromofreq(1,2)-1065;

urnpromos = zeros(8727,1);


urnxpromocost= 0;
urn2fullness = 0;
m = 0;
while(m < length(adjpromofreq))
    m = m + 1;
    
    urnxpromocost = adjpromofreq(m,2);
    
    n = 0;
    while(n < urnxpromocost)
        n = n + 1;
        urnpromos(urn2fullness + n,1) = adjpromofreq(m,1);                 
    end
    
    urn2fullness = urn2fullness + urnxpromocost;
end

% ************************************************************************
% Now for the actual simulating.

% % I will do this in two steps.
% simsmultiplier = 1000;
% 
% asymptpop = zeros(1065, 1000);
% 
% y = 0;
% 
% while(y < simsmultiplier)
%     y = y + 1
    
    
    numberofuniquesponsors = 1065;          % Number of sponsors
    numberofsims = 1000;                    % Number of simulations


    % This matrix contains the average costs for each simulation.
    fauxpop = zeros(numberofuniquesponsors,numberofsims);

    % This will hold information for one simulation (the current one).There
    % are two columns: (1) Number of drives for the sponsor; (2) Average
    % promocost across all drives for the sponsor.
    fauxpeople = zeros(numberofuniquesponsors,2);
    fauxpeople(:,1) = urndrives;

    % Note the important urns are:
    % 1) urndrives 
    % 2) urnpromos

    p = 0;
    while(p < numberofsims)    
        p = p + 1

        drawingurnP = urnpromos;  % This is the urn I draw from till empty

        % First issue to go through and fill each sponsor with a zero AND
        % non-zero promocost. The zero event is simple, I only need to loop
        % through each sponsor for N-1 of their N drives, while still
        % averaging over N drives. The non-zero loop-through less so. I
        % think two loops will be the easiest way to do this. One loop
        % through for non-zero entries and on with all remaining entries.

        % NON-ZERO LOOP
        % Note: There are 5604 zero entries remaining after each sponsor is
        % allocated a mandatory zero entry.
        r = 0;
        while(r < numberofuniquesponsors)
            r = r + 1;

            randnozero = round(5605 + (length(drawingurnP)-5605)*rand);
            fauxpeople(r,2) = drawingurnP(randnozero);

            drawingurnP(randnozero) = [];
        end
    	%     sortrows(fauxpeople,1)
    	%     sortrows(fauxpeople,2)
        % FILL THE REST!
        s = 99;     %Note - there are 99 sponsors with 2 drives
        while(s < numberofuniquesponsors)
            s = s + 1;


            nodrives = fauxpeople(s,1);

            t = 0;
            while(t < (nodrives - 2))
                t = t + 1;

                randrest = round(1 + (length(drawingurnP)-1)*rand);
                fauxpeople(s,2) = fauxpeople(s,2) + drawingurnP(randrest);

                drawingurnP(randrest) = [];
            end


        end

        fauxpeople(:,2) = fauxpeople(:,2)./fauxpeople(:,1); 
        fauxpeople = sortrows(fauxpeople,2);
        fauxpop(:,p) = fauxpeople(:,2);
    end

    



% end



% ************************************************************************
% I have run the simulation 1000 times and use the following section to
% save the output, rather then re-running the simulation each time.
dlmwrite('final2.txt',fauxpop,'delimiter', '\t','precision','%.6f');


% Read in saved data!
fauxpop = [];
fid = fopen('final2.txt');     % Read in the file (into Binary format?)

while 1                         % Loop to read each line of text
    tline = fgetl(fid);         % fgetl() reads each line
    if ~ischar(tline),   break,   end
    a = str2num(tline);         % I believe this converts a string 
    fauxpop = [fauxpop;a];                  % Fill the matrix!
end


% ************************************************************************
% This section sorts the simulated data horizontally, in ascending order.

u = 0;
size(fauxpop)
arow = zeros(1065,1);
fauxpopsort = zeros(1065,1000);

while(u < 1065)
    u = u + 1;
    
    arow = fauxpop(u,:);
    
    % Note: sortrows() only works on row vectors, not column ones.
    arow = sortrows(arow');
    fauxpopsort(u,:) = arow;
    
end

% Find the average of the rows and append it to the end of the matrix.
ultimean = mean(fauxpopsort,2)
size(fauxpopsort)

% I have add the row averages to the end of the matrix of horizontally and
% vertically sorted simulated values.
fauxpopnmean =[fauxpopsort ultimean];
size(fauxpopnmean)

% ************************************************************************
% Now what I need to do is get the 1% Quartiles. Due to the strange length
% of the matrix (1065), I have to average over two bins to get the 1%
% quartiles. For example, the first quartile is the 10.65th value, which is
% 0.65 of the 10th value and 0.35 of the 11th value.

qfauxpop = zeros(100,1001);

% This was done above for actual, it is being redefined again:
% Creating a (100,1) vector of positions: 10.65, 21.30, etc
quartiles = [10.65:10.65:1065]'

% Make this vector a (100x3) matrix where the second column rounds the
% first one down and the third rounds it up. Thus I have the appropriate
% positions to average over.
quartiles = [quartiles floor(quartiles) ceil(quartiles)]

size(quartiles)

v = 0;
while(v < length(quartiles))
    v = v + 1;
    
    % The difference between the actual value and the rounded down value
    % gives me the weight for the lower value. (1 - difference) gives me
    % the weight for the upper value. For example: 10.65 - 10 = 0.65,
    % making the average 0.65*10th position + (1-0.65)*11th position.
    diff = quartiles(v,1) - quartiles(v,2);
    lower = quartiles(v,2);
    upper = quartiles(v,3);
    
    qfauxpop(v,:) = diff*fauxpopnmean(lower,:) + (1-diff)*fauxpopnmean(upper,:);
    
end

% ************************************************************************

% Vector of values going up by 10. Starting at 10 and finishing at 1000.
tenthcol = [10:10:1000];

tenthfauxpop = zeros(100,101);
w = 0;
while(w < length(tenthcol))
    w = w + 1;
    tenthfauxpop(:,w) = qfauxpop(:,tenthcol(w));
    
end
tenthfauxpop(:,101) = qfauxpop(:,1001);

dlmwrite('tenths2.xls',tenthfauxpop,'delimiter', '\t','precision','%.6f');

% ALL DATA ANALYSIS, MANIPULATION AND SIMULATION IS NOW COMPLETE.
% ************************************************************************

% Some plots
plot(1:1:100,actualtenths,'--r',1:1:100,tenthfauxpop(:,1),'.g',1:1:100,tenthfauxpop(:,99),'.b')


% ************************************************************************
sum(qfauxpop(100,:) - fauxpopmean(1065,:))

zz = ones(3,3)

zz = [zz; 0 0 0]

zz(1,:) = 0.5*zz(3,:) + 0.5*zz(4,:)



vars = std(transpose(fauxpop));
varcol = std(fauxpop);

plot(fauxpeople(:,2))
scatter(1:1:1065,fauxpeople(:,2),'.')
scatter(1:1:1000,fauxpop(530,:),'.')

scatter(1:1:1065,vars,'.')
scatter(1:1:1000,varcol,'.')

scatter(1:1:1000,fauxpop(50,:))

plot(fauxpop(:,50),1:1:1065,ultimean,1:1:1065,fauxpop(:,950),1:1:1065)
plot(1:1:1065,ultimean)

*****************************************************************************************
*****************************************************************************************

**** END */ ;

