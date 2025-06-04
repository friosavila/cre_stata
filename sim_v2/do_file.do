log using sim_v2/main_log, replace

display "***********************************************" _n ///
		" ------------- PAPER REPLICATION --------------" _n ///
		"***********************************************"
webuse nlswork, clear
xtset idcode year
gen wage = exp(ln_wage) // Transform log wage to wage for poisson model
gen white = race==1 & race!=.
global depvar1 ln_wage
global depvar2 wage
global depvar3 union
global indep "c.age##c.age c.tenure##c.tenure i.white i.south"

drop if wage==. | white==.  | age==. | tenure==. | south==.
// 1. Fixed Effects (xtreg, fe)
xtreg $depvar1 $indep, fe  
est sto m1
// 2. Random Effects (xtreg, re)
xtreg $depvar1 $indep, re  
est sto m2
// 3. Stata's built-in CRE (xtreg, cre)
xtreg $depvar1 $indep, cre
est sto m3
// CRE prefix - xtreg
cre, abs(idcode): xtreg $depvar1 $indep, re  
est sto m4
// CRE prefix - regress
cre, abs(idcode): reg $depvar1 $indep, cluster(idcode)  
est sto m5

esttab m1 m2 m3 m4 m5, drop(0.*) nogaps ///
mtitle("xtreg FE" "xtreg RE" "xtreg CRE" "CRE XTREG" "CRE Regress") b(3) t ///
nonum nostar tex


// 1. Fixed Effects (xtreg, fe)
xtreg $depvar1 $indep, fe  vce(robust)
est sto m1
// 2. Random Effects (xtreg, re)
xtreg $depvar1 $indep, re  vce(robust)
est sto m2
// 3. Stata's built-in CRE (xtreg, cre)
xtreg $depvar1 $indep, cre vce(robust)
est sto m3
// CRE prefix - xtreg
cre, abs(idcode): xtreg $depvar1 $indep, re  vce(robust)
est sto m4
// CRE prefix - regress robust
cre, abs(idcode): reg $depvar1 $indep, cluster(idcode)  
est sto m5
esttab m1 m2 m3 m4 m5, drop(0.*) nogaps ///
mtitle("xtreg FE" "xtreg RE" "xtreg CRE" "CRE XTREG" "CRE Regress") b(3) t ///
nonum nostar tex

** For Appendix Poisson and Linreg
reghdfe $depvar1 $indep, abs(idcode year) vce(robust)
est sto m1
ppmlhdfe $depvar2 $indep, abs(idcode year) vce(robust)
est sto m2
cre, abs(idcode year):reg $depvar1 $indep, robust
est sto m3
cre, abs(idcode year):poisson $depvar2 $indep, robust
est sto m4
esttab m1 m2 m3 m4 , drop(0.*) nogaps ///
mtitle("reghdfe" "ppmlhdfe" "CRE regress" "CRE poisson") b(3) t ///
nonum nostar tex

** Poisson


webuse nlswork, clear
xtset idcode year
gen wage = exp(ln_wage) // Transform log wage to wage for poisson model
gen white = race==1 & race!=.
global depvar1 ln_wage
global depvar2 wage
global depvar3 union
global indep "c.age##c.age c.tenure##c.tenure i.white i.south"

drop if white==. | wage==. | age==. | tenure==. | south==.
bysort idcode:gen nobs=_N
drop if nobs==1

gen age_sqr = age*age
gen tenure_sqr  = tenure*tenure
global indep2 "age age_sqr tenure tenure_sqr white south"


xtpoisson $depvar2 $indep, fe vce(robust)
est sto m1
xtpoisson $depvar2 $indep, re vce(robust)
est sto m2
xthybrid $depvar2 $indep2 , clusterid(idcode) vce(robust) family(poisson) link(log)  cre se
est sto m3
cre, abs(idcode): poisson $depvar2 $indep, cluster(idcode)
est sto m4
cre, abs(idcode): xtpoisson $depvar2 $indep, re vce(robust)
est sto m5
meglm  $depvar2 $indep m1_* || idcode:, family(poisson) link(log) vce(robust)
est sto m6

esttab m1 m2 m3 m4 m5 m6 , drop(0.*) nogaps ///
			mtitle("xtpoisson FE" "xtpoisson RE" "xthybrid" ///
			"CRE Poisson" "CRE xtpoisson" "CRE meglm") b(3) t ///
			rename(R__white 1.white  ///
			W__age    age W__age_sqr c.age#c.age ///
			W__tenure tenure  W__tenure_sqr c.tenure#c.tenure W__south   1.south ///
			D__age    m1_age D__age_sqr m1_c_age_c_age ///
			D__tenure m1_tenure  D__tenure_sqr m1_c_tenure_c_tenure D__south   m1__1_south) ///
			nose nostar  tex
			

qui:ppmlhdfe $depvar2 $indep, abs(idcode) vce(robust) d
margins, dydx(age tenure) post  
est sto m1mfx
qui:cre, abs(idcode): poisson $depvar2 $indep, cluster(idcode)
margins, dydx(age tenure) post  
est sto m2mfx
qui:meglm  $depvar2 $indep m1_* || idcode:, family(poisson) link(log) vce(robust)
margins, dydx(age tenure) post  
est sto m3mfx

esttab m1mfx m2mfx m3mfx,  nogaps ///
			mtitle("ppmlhdfe" "CRE poisson" "CRE meglm") b(3) t ///
			nose nostar   tex

			
			
** logit

webuse nlswork, clear
xtset idcode year
gen wage = exp(ln_wage) // Transform log wage to wage for poisson model
gen white = race==1 & race!=.
global depvar1 ln_wage
global depvar2 wage
global depvar3 union
global indep "c.age##c.age c.tenure##c.tenure i.white i.south"

drop if white==. | union==. | age==. | tenure==. | south==.
bysort idcode:gen nobs=_N
drop if nobs==1		
bysort idcode:egen sig_union=sd(union)
drop if sig_union==0 | sig_union==.


xtlogit $depvar3 $indep, fe  
margins, dydx(age tenure) post
est sto m1mfx
xtlogit $depvar3 $indep, re vce(robust)
margins, dydx(age tenure) post
est sto m2mfx
qui:cre, abs(idcode): logit $depvar3 $indep, cluster(idcode)
margins, dydx(age tenure) post
est sto m3mfx
qui:cre, abs(idcode): xtlogit $depvar3 $indep, re vce(robust) 
margins, dydx(age tenure) post
est sto m4mfx


esttab m1mfx m2mfx m3mfx m4mfx, nogaps ///
			mtitle("xtlogit FE" "xtlogit RE"  ///
			"CRE logit" "CRE xtlogit RE" ) b(3) t ///
			nose nostar  tex
			
log close			