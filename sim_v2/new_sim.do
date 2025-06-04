log using sim_v2/main_log, append
version 19
display "***********************************************" _n ///
		" ------------- Simulation 1fe    --------------" _n ///
		"***********************************************"
// setup
net install parallel, from(https://raw.github.com/gvegayon/parallel/stable/) replace
ssc install estout
set scheme stsj
 
// Simulation program
capture program drop cre_sim_1fe
program define cre_sim_1fe, eclass
	syntax, [model(int 1)]
	clear
	set obs 1000
	// Generates indicators for the two fixed effects
	gen id1 = runiformint(1,100)
	// fixed effects are assumed follow a uniform distribution
	gen c1 = runiform(-.5,.5)
	bysort id1:replace c1=c1[1]
	// explanatory variables are correlated with the fixed effects, 
	// thus correlated with each other
	gen x1 = runiform(-1,1)+invnormal(c1+.5)
	gen x2 = runiform(-1,1)-invnormal(c1+.5)
	// and the expected latent ey_star is a linear combination x1, x2, c1, and c2
	gen y_star = 1 + x1 + x2 + c1 
	if `model'==1 {
		// probit
		gen y_probit = 1*(y_star-1+rnormal()>0)
		probit y_probit x1 x2 c1 
		margins, dydx(x1 x2) post
		matrix b_true = _b[x1],_b[x2]
		probit y_probit x1 x2
		margins, dydx(x1 x2) post
		matrix b_nofe = _b[x1],_b[x2]
		cre, abs(id1 ): probit y_probit x1 x2
		margins, dydx(x1 x2) post
		matrix b_cre = _b[x1],_b[x2]
	}
	else if `model'==2 {
		// fractional probit
		gen y_fprobit = normal(y_star-1+rnormal())
		fracreg probit y_fprobit x1 x2 c1 
		margins, dydx(x1 x2)
		matrix b_true = _b[x1],_b[x2]
		fracreg probit y_fprobit x1 x2
		margins, dydx(x1 x2)
		matrix b_nofe = _b[x1],_b[x2]
		cre, abs(id1 ): fracreg probit y_fprobit  x1 x2
		margins, dydx(x1 x2)
		matrix b_cre = _b[x1],_b[x2]
	}
	else if `model'==3 {
		// tobit
		gen y_tobit = max( y_star + rnormal(),0)
		tobit y_tobit x1 x2 c1 , ll(0)
		matrix b_true = _b[x1],_b[x2]
		tobit y_tobit  x1 x2, ll(0)
		matrix b_nofe = _b[x1],_b[x2]
		cre, abs(id1 ): tobit y_tobit x1 x2, ll(0)
		matrix b_cre = _b[x1],_b[x2]
	}
	else if `model'==4 {
		// poisson
		gen y_poisson = rpoisson(exp(y_star))
		poisson y_poisson x1 x2 c1  
		matrix b_true = _b[x1],_b[x2]
		poisson y_poisson  x1 x2
		matrix b_nofe = _b[x1],_b[x2]
		cre, abs(id1 ): poisson y_poisson x1 x2
		matrix b_cre = _b[x1],_b[x2]
		
	}

matrix coleq b_true = true
matrix coleq b_nofe = nofe
matrix coleq b_cre  = cre 
matrix colname b_true = x1 x2
matrix colname b_nofe = x1 x2
matrix colname b_cre = x1 x2
matrix b = b_true,b_nofe,b_cre

ereturn post b

end
 
 
 
parallel initialize 16
global seed 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
parallel sim , reps(10000) seeds($seed): cre_sim_1fe, model(1)
save sim_v2/cre_probit, replace

parallel sim , reps(10000) seeds($seed): cre_sim_1fe, model(2)
save sim_v2/cre_fprobit, replace

parallel sim , reps(10000) seeds($seed): cre_sim_1fe, model(3)
save sim_v2/cre_tobit, replace

parallel sim , reps(10000) seeds($seed): cre_sim_1fe, model(4)
save sim_v2/cre_poisson, replace



use sim_v2/cre_probit, clear
two (kdensity  true_b_x1) (kdensity  nofe_b_x1) (kdensity  cre_b_x1 ) , ///
	legend(order(1 "Unfeasible" 2 "Pool Data no FE" 3 "CRE") col(3)) xtitle("Marginal Effect X1") ///
	name(f1, replace) title(Probit)
sum true_b_x1	
gen mean=r(mean)

foreach i of  varlist *x1 {
 gen c`i'=`i'-mean
 gen c2`i'=abs(`i'-mean)
 }
estpost tabstat ctrue_b_x1 c2true_b_x1 cnofe_b_x1 c2nofe_b_x1 ccre_b_x1 c2cre_b_x1,  columns(statistics)
est sto m1

	
use sim_v2/cre_fprobit, clear
two (kdensity  true_b_x1) (kdensity  nofe_b_x1) (kdensity  cre_b_x1 ) , ///
	legend(order(1 "Unfeasible" 2 "Pool Data no FE" 3 "CRE") col(3)) xtitle("Marginal Effect X1") ///
	name(f2, replace) title(Fractional Probit)
sum true_b_x1	
gen mean=r(mean)

foreach i of  varlist *x1 {
 gen c`i'=`i'-mean
 gen c2`i'=abs(`i'-mean)
 }
estpost tabstat ctrue_b_x1 c2true_b_x1 cnofe_b_x1 c2nofe_b_x1 ccre_b_x1 c2cre_b_x1,  columns(statistics)
est sto m2
	
use sim_v2/cre_tobit, clear
two (kdensity  true_b_x1) (kdensity  nofe_b_x1) (kdensity  cre_b_x1 ) , ///
	legend(order(1 "Unfeasible" 2 "Pool Data no FE" 3 "CRE") col(3)) xtitle("Marginal Effect X1") ///
	name(f3, replace) title(Tobit) 
sum true_b_x1	
gen mean=r(mean)

foreach i of  varlist *x1 {
 gen c`i'=`i'-mean
 gen c2`i'=abs(`i'-mean)
 }
estpost tabstat ctrue_b_x1 c2true_b_x1 cnofe_b_x1 c2nofe_b_x1 ccre_b_x1 c2cre_b_x1,  columns(statistics)
est sto m3
	
use sim_v2/cre_poisson, clear
two (kdensity  true_b_x1) (kdensity  nofe_b_x1) (kdensity  cre_b_x1 ) , ///
	legend(order(1 "Unfeasible" 2 "Pool Data no FE" 3 "CRE") col(3)) xtitle("Marginal Effect X1") ///
	name(f4, replace) title(Poisson)
sum true_b_x1	
gen mean=r(mean)

foreach i of  varlist *x1 {
 gen c`i'=`i'-mean
 gen c2`i'=abs(`i'-mean)
 }
estpost tabstat ctrue_b_x1 c2true_b_x1 cnofe_b_x1 c2nofe_b_x1 ccre_b_x1 c2cre_b_x1,  columns(statistics)
est sto m4

graph combine f1 f2 f3 f4	, nocopies altshrink scale(1.1)
graph export sim_v2/fig1.png, replace width(1000)


esttab m1 m2 m3 m4 using sim_v2/table1.txt, cell(mean(fmt(3))) nonum mtitle(Probit FProbit Tobit Poisson) collab(none) ///
	varlabel(ctrue_b_x1 "True:Bias" c2true_b_x1 "True:MAE" cnofe_b_x1 "Pool:Bias" c2nofe_b_x1 "Pool:MAE" ccre_b_x1 "CRE:Bias"c2cre_b_x1 "CRE:MAE") md replace

log close	