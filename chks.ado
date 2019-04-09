*! Version 1.1 March2019.
*! Program: chks (Chancí, Kumbhakar and Sandoval, 2019)
*! Author : Luis Chancí
*! email  : lchanci1 at binghamton dot edu
*! net install chks, replace from ("https://luischanci.github.io/chks/")
cap pro drop chks
pro chks, eclass
version 14.2
syntax varlist (min=2) 		/// minimun one ind. variable
	   [if] [in] 			///
	   [, 					///
	   INdx(varlist) 		/// Index      		  : Other Ym variables
	   Type(string)			/// Type       		  : cd,ces
	   EStimation(string)	/// Estimation 		  : nls,sf,zsf
	   EOption(string)		/// Estimation Option : ml, em (for EM-Algorithm)
	   noCONstant 			///
	   Robust 				///
	   ]

	local depvar: word 1 of `varlist'
	local regs  : list varlist - depvar

	marksample touse
	preserve
	markout `touse' `indx'

**********************************ERRORS
	if ("`type'" != "" & "`type'" != "cd" & "`type'" != "ces") {
		di "{err}{cmd:type()} incorrectly specified"
		exit 7
	}

	if ("`estimation'" != "" & "`estimation'" != "nls" & "`estimation'" != "sf" & "`estimation'" != "zsf") {
		di "{err}{cmd:estimation()} incorrectly specified"
		exit 7
	}

	if ("`eoption'" != "" & "`eoption'" != "ml" & "`eoption'" != "em") {
		di "{err}{cmd:eoption()} incorrectly specified"
		exit 7
	}

**********************************END ERRORS

**********************************To aviod issues in Mata
	tempname checkingmissing_a checkingmissing_b b V

	/* Checking potential errors with missing values */
	qui{
	 gen  double checkingmissing_a = ln(`depvar')
	 egen 		 checkingmissing_b = rowmiss(checkingmissing_a  ///
									`regs' `indx')
	 drop if 	checkingmissing_b == 1
	 drop 		checkingmissing*
	}
**********************************END INITIAL CHECK


**********************************ESTIMATION
	if "`indx'" == "" {
		if	"`type'" == "" {
			if ("`estimation'" == "" | "`estimation'" == "nls") {
				display "Linear function. (Least Squares)"
				reg `depvar' `regs', `constant' `robust'
			}
			else if "`estimation'" == "sf" {
				display "Linear function. (Stochastic Frontier)"
				frontier `depvar' `regs', `constant'
			}
			else if "`estimation'" == "zsf" {
				di "Zero Stochastic Frontier for linear models"
				mata: chks_m("`depvar'", "`regs'", "`indx'", "`touse'", ///
							"`type'","`estimation'","`eoption'", 		///
							"`constant'","`robust'")
				mat     `b' = r(beta)
				mat     `V' = r(V)
				local vnames `regs' _cons lnsigma_u lnsigma_v logist_probability
				if ("`constant'" != "") {
					local vnames `regs' lnsigma_u lnsigma_v logist_probability
				}
				matrix  colnames `b' = `vnames'
				matrix  rownames `b' = `depvar'
				matrix  colnames `V' = `vnames'
				matrix  rownames `V' = `vnames'
				ereturn post `b' `V', depname(`depvar') esample(`touse')
				ereturn display
			}
		}
		else {
			di "{err}Incorrectly specified. {cmd:type()} only if {cmd:indx()} no empty."
			exit 7
		}
	}
	else {
		if	"`type'" == "" {
			if ("`estimation'" != "zsf") {
			  if ("`estimation'" == "" | "`estimation'" == "nls") {
				display "Linear Index.(Least Squares)"
				qui reg `depvar' `regs' `indx', `constant' `robust'
			    }
			  else if ("`estimation'" == "sf") {
				display "Linear Index.(Stochastic Frontier)"
				qui frontier `depvar' `regs' `indx', `constant'
			    }
			  mat beta = e(b)
			  mat V    = e(V)
			  local nX : word count `regs'
			  local nY : word count `indx'
			  local np `=colsof(beta)'
			  mat   b   = (beta[1,1..`nX'], 			  ///
						  -beta[1,(`nX'+1)..(`nX'+`nY')], ///
						   beta[1,(`nX'+`nY'+1)..(`np')])
				ereturn post b V, depname(`depvar')
				ereturn display
			}
			else {
				display "Linear Index.(Zero - Stochastic Frontier)"
				mata: chks_m("`depvar'", "`regs'", "`indx'", "`touse'", ///
						 "`type'","`estimation'","`eoption'", 		    ///
						 "`constant'","`robust'")

				mat     `b' = r(beta)
				mat     `V' = r(V)
			    local vnames `regs' _cons `indx' lnsigma_u lnsigma_v logist_probability
				matrix  colnames `b' = `vnames'
				matrix  rownames `b' = `depvar'
				matrix  colnames `V' = `vnames'
				matrix  rownames `V' = `vnames'
				ereturn post `b' `V', depname(`depvar') esample(`touse')
				ereturn display
			}
		}
		else {
			if ("`estimation'" == "") {
				di "{err}Non-linear model. Missing {cmd:estimation()} - nls, sf, zsf."
				exit
			}
			mata: chks_m("`depvar'", "`regs'", "`indx'", "`touse'", ///
						 "`type'","`estimation'","`eoption'", 		///
						 "`constant'","`robust'")
			mat     `b' = r(beta)
			mat     `V' = r(V)
			local vnames `regs' _cons `indx'
			if ("`constant'" != "") {
				local vnames `regs' `indx'
			}
			if "`type'" == "ces" {
				local vnames `vnames' rho
			}
			if "`estimation'" == "sf" {
				local vnames `vnames' lnsigma_u lnsigma_v
			}
			if "`estimation'" == "zsf" {
				local vnames `vnames' lnsigma_u lnsigma_v logist_probability
			}
			matrix  colnames `b' = `vnames'
			matrix  rownames `b' = `depvar'
			matrix  colnames `V' = `vnames'
			matrix  rownames `V' = `vnames'
			ereturn post `b' `V', depname(`depvar') esample(`touse')
			ereturn display
		}
	}
	restore
end

/********************************************/

version 14.2
mata:
mata clear
void fn_nl(todo, b, Y, X, to, cri, g, H)
{
	betas = b[.,1::cols(X)]
	Xb    = X*betas'

	Y1	  = Y[.,1]
	YM	  = Y[.,2::cols(Y)]

	delta = b[.,(cols(X)+1)::(cols(X)+cols(YM))]
	rho   = 1
	if (to== 2)(rho = b[.,cols(b)]);;
	Yd    = (-1/rho)*ln((((YM:/Y1):^rho:-1)*delta'):+1)

    cri   = (ln(Y[.,1]) - (Yd + Xb)):^2
}
void fn_sf(todo, b, Y, X, to, cri, g, H)
{
	betas = b[.,1::cols(X)]
	Xb    = X*betas'

	YM	  = Y[.,2::cols(Y)]
	Y1	  = Y[.,1]

	if (to == 1) {
		delta = b[.,(cols(X)+1)::(cols(b)-2)]
		Yd	  = -1*ln((((YM:/Y1):-1)*delta'):+1)
	}
	else {
		delta = b[.,(cols(X)+1)::(cols(b)-3)]
	    rho	  = b[.,(cols(b)-2)]
		Yd    = (-1/rho)*ln((((YM:/Y1):^rho:-1)*delta'):+1)
	}

	su    = exp(b[.,(cols(b)-1)])
	sv	  = exp(b[.,cols(b)])
	s	  = sqrt(su^2 + sv^2)
	lam   = su/sv

    cri = ln(2):+lnnormalden(ln(Y1),Xb+Yd,s) +
				 lnnormal(-(ln(Y1)-Xb-Yd)*(lam/s))
}
void fn_zsf_ml(todo, b, Y, X, op, cri, g, H)
{
	betas = b[.,1::cols(X)]
	Xb    = X*betas'

	SU    = exp(b[.,(cols(b)-2)])
	SV	  = exp(b[.,(cols(b)-1)])
	S	  = sqrt(SU^2 + SV^2)
	LAM   = SU/SV

	P	  = exp(b[.,cols(b)])/(1 + exp(b[.,cols(b)]) )

	MU	  = Xb

	Y1	  = Y[.,1]

	if (op[1] == 0) {

		cri = ln(  P *   normalden(Y1,MU,SV) + 						 /*
		*/	    (1-P)*(2*normalden(Y1,MU,S)  :* normal((Y1-MU)*LAM/S)) )
	}
	else {
		YM	  = Y[.,2::cols(Y)]

		delta = b[.,(cols(X)+1)::(cols(X)+cols(YM))]
		rho   = 1

		if (op[2] == 2)(rho=b[.,(cols(b)-3)]);;

		Yd    = (-1/rho)*ln((((YM:/Y1):^rho:-1)*delta'):+1)

		MU	  = MU + Yd

		cri   = ln(  P *   normalden(ln(Y1),MU,SV) + 						 /*
		*/	      (1-P)*(2*normalden(ln(Y1),MU,S)  :* normal((ln(Y1)-MU)*LAM/S)) )
	}
}
void fn_zsf_em(todo, b, Y, X, r, op, cri, g, H)
{
	betas = b[.,1::cols(X)]
	Xb    = X*betas'

	SU    = exp(b[.,(cols(b)-2)])
	SV	  = exp(b[.,(cols(b)-1)])
	S	  = sqrt(SU^2 + SV^2)
	LAM   = SU/SV

	P	  = exp(b[.,cols(b)])/(1 + exp(b[.,cols(b)]) )

	MU	  = Xb

	Y1	  = Y[.,1]

	if (op[1] == 0) {

		cri   =   r  *ln(P) +
			  (1:-r) *ln(1-P) +
				  r :*lnnormalden(Y1,MU,SV) +
			  (1:-r):*( ln(2):+
						lnnormalden(Y1,MU,S)+
						lnnormal(-(Y1-MU)*LAM/S))
	}
	else {
		YM	  = Y[.,2::cols(Y)]

		delta = b[.,(cols(X)+1)::(cols(X)+cols(YM))]
		rho   = 1

		if (op[2] == 2)(rho=b[.,(cols(b)-3)]);;

		Yd    = (-1/rho)*ln((((YM:/Y1):^rho:-1)*delta'):+1)

		MU	  = MU + Yd

		cri   =   r  *ln(P) +
			  (1:-r) *ln(1-P) +
				  r :*lnnormalden(ln(Y1),MU,SV) +
			  (1:-r):*( ln(2):+
						lnnormalden(ln(Y1),MU,S)+
						lnnormal(-(ln(Y1)-MU)*LAM/S))
	}
}
void chks_m(string scalar yname,
			string scalar xnames,
			string scalar indxnames,
			string scalar touse,
			string scalar t_opt,
			string scalar e1_opt,
			string scalar e2_opt,
			string scalar c_opt,
			string scalar r_opt)
{
	st_view(Y1,., tokens(yname), touse)
	st_view(X,., tokens(xnames), touse)

	if (indxnames != "")(st_view(YM,.,tokens(indxnames), touse));;
	if (c_opt == "")( X = (X , J(rows(X),1,1)) );;

	maxite = 200

if (e1_opt != "zsf"){
S =	optimize_init()
	optimize_init_argument(S,1,(Y1,YM))
	optimize_init_argument(S,2,X)

	b0 = (invsym((X,-YM)'(X,-YM))*((X,-YM)'ln(Y1)))'

	if (e1_opt == "nls") {

		if (t_opt == "cd") {
			to = 1
			np = cols(X) + cols(YM)
			b0 = b0
		}
		else {
			to = 2
			np = cols(X) + cols(YM) + 1
			b0 = (b0 , 0.8)
		}
		optimize_init_evaluator(S, &fn_nl())
		optimize_init_which(S,"min" )
	}
	else if (e1_opt == "sf") {

		if (t_opt == "cd") {
			to = 1
			np = cols(X) + cols(YM) + 2
			b0 = (b0 , -1 , -1)
		}
		else {
			to = 2
			np = cols(X) + cols(YM) + 3
			b0 = (b0 , 1 , -1 , -1)
		}

		optimize_init_evaluator(S, &fn_sf())
		optimize_init_which(S,"max" )
	}
	optimize_init_argument(S,3,to)
	optimize_init_params(S, b0)
	optimize_init_evaluatortype(S, "gf0")
	optimize_init_conv_maxiter(S,maxite)
b =	optimize(S)
}
else {
	if (indxnames == "") {
		display("(ZSF. Linear model.)")
		lf = 0
		b0 = ((invsym(X'X)*(X'Y1))' , -1 , -1 , 1.3)
		np = cols(X) + 3

		if (e2_opt == "ml") {
			S =	optimize_init()
				optimize_init_argument(S,1,Y1)
				optimize_init_argument(S,2,X)
				optimize_init_argument(S,3,(lf,0))
				optimize_init_params(S,b0)
				optimize_init_evaluator(S, &fn_zsf_ml())
				optimize_init_conv_maxiter(S,maxite)		 /* later: maxit */
				optimize_init_evaluatortype(S,"gf0")
				optimize_init_which(S,"max")
			b = optimize(S)
				display(" (Zero) Stochastic Frontier, linear model. M.L.E. ")
		}
		else {
			lk0 = 1
			tol = 1
			ite = 1
			while (tol > 1e-6 & ite <= maxite) {
				betas = b0[.,1::cols(X)]
				Xb    = X*betas'

				SU    = exp(b0[.,(cols(b0)-2)])
				SV	  = exp(b0[.,(cols(b0)-1)])
				S     = sqrt(SU^2 + SV^2)
				LAM   = SU/SV

				P	  = exp(b0[.,cols(b0)])/(1 + exp(b0[.,cols(b0)]) )

				MU    = Xb

				r	  = P*normalden(Y1,MU,SV):/ /*
				*/	   (P*normalden(Y1,MU,SV) + /*
				*/     (1-P)*2*normalden(Y1,MU,S):*normal(-(Y1-MU)*LAM/S))

				S   = optimize_init()
					  optimize_init_evaluator(S, &fn_zsf_em())
					  optimize_init_argument(S,1,Y1)
					  optimize_init_argument(S,2,X)
					  optimize_init_argument(S,3,r)
					  optimize_init_argument(S,4,(lf,0))
					  optimize_init_params(S, b0)
					  optimize_init_evaluatortype(S,"gf0")
					  optimize_init_which(S,"max" )
					  optimize_init_conv_maxiter(S,maxite)
				b   = optimize(S)
				lk  = optimize_result_value(S)
				tol	= abs(lk - lk0)
				b0	= b
				lk0 = lk
				ite	= ite + 1
			}
			display(" (Zero) Stochastic Frontier, linear model. EM-Algorithm. ")
		}
	}
	else {
	 if (t_opt == "") {
		display("(ZSF. Linear model.)")
		lf = 0
		X  = (X,YM)
		b0 = ((invsym(X'X)*(X'Y1))' , -1 , -1 , 1.3)
		np = cols(X) + cols(YM) + 3

		if (e2_opt == "ml") {
			S =	optimize_init()
				optimize_init_argument(S,1,Y1)
				optimize_init_argument(S,2,X)
				optimize_init_argument(S,3,(lf,0))
				optimize_init_params(S,b0)
				optimize_init_evaluator(S, &fn_zsf_ml())
				optimize_init_conv_maxiter(S,maxite)		 /* later: maxit */
				optimize_init_evaluatortype(S,"gf0")
				optimize_init_which(S,"max")
			b = optimize(S)
				display(" (Zero) Stochastic Frontier, linear model. M.L.E. ")
		}
		else {
			lk0 = 1
			tol = 1
			ite = 1
			while (tol > 1e-6 & ite <= maxite) {
				betas = b0[.,1::cols(X)]
				Xb    = X*betas'

				SU    = exp(b0[.,(cols(b0)-2)])
				SV	  = exp(b0[.,(cols(b0)-1)])
				S     = sqrt(SU^2 + SV^2)
				LAM   = SU/SV

				P	  = exp(b0[.,cols(b0)])/(1 + exp(b0[.,cols(b0)]) )

				MU    = Xb

				r	  = P*normalden(Y1,MU,SV):/ /*
				*/	   (P*normalden(Y1,MU,SV) + /*
				*/     (1-P)*2*normalden(Y1,MU,S):*normal(-(Y1-MU)*LAM/S))
				S   = optimize_init()
					  optimize_init_evaluator(S, &fn_zsf_em())
					  optimize_init_argument(S,1,Y1)
					  optimize_init_argument(S,2,X)
					  optimize_init_argument(S,3,r)
					  optimize_init_argument(S,4,(lf,0))
					  optimize_init_params(S, b0)
					  optimize_init_evaluatortype(S,"gf0")
					  optimize_init_which(S,"max" )
					  optimize_init_conv_maxiter(S,maxite)
				b   = optimize(S)
				lk  = optimize_result_value(S)
				tol	= abs(lk - lk0)
				b0	= b
				lk0 = lk
				ite	= ite + 1
			}
			display(" (Zero) Stochastic Frontier. linear model. EM-Algorithm. ")
		}
	 }
	 else {
		display("(ZSF. Non-linear model.)")
		lf = 1
		b0  = invsym((X,-(YM:/Y1))'(X,-(YM:/Y1)))*((X,-(YM:/Y1))'ln(Y1))
		if (t_opt == "cd") {
			to = 1
			b0 = (b0' , -1 , -1 , 1.3)
			np = cols(X) + cols(YM) + 3
		}
		else {
			to = 2
			b0 = (b0' , 1, -1 , -1 , 1.3)
			np = cols(X) + cols(YM) + 4
		}

		op = (lf,to)

		if (e2_opt == "ml") {
			S =	optimize_init()
				optimize_init_argument(S,1,(Y1,YM))
				optimize_init_argument(S,2,X)
				optimize_init_argument(S,3,op)
				optimize_init_params(S,b0)
				optimize_init_evaluator(S, &fn_zsf_ml())
				optimize_init_conv_maxiter(S,maxite)
				optimize_init_evaluatortype(S,"gf0")
				optimize_init_which(S,"max")
			b = optimize(S)
				display(" (Zero) Stochastic Frontier. Non-linear model. M.L.E. ")
		}
		else {
			lk0 = 1
			tol = 1
			ite = 1
			while (tol > 1e-6 & ite <= maxite) {
				betas = b0[.,1::cols(X)]
				Xb    = X*betas'

				SU    = exp(b0[.,(cols(b0)-2)])
				SV	  = exp(b0[.,(cols(b0)-1)])
				S     = sqrt(SU^2 + SV^2)
				LAM   = SU/SV

				P	  = exp(b0[.,cols(b0)])/(1 + exp(b0[.,cols(b0)]) )

				MU    = Xb

				delta = b0[.,(cols(X)+1)::(cols(X)+cols(YM))]
				rho	  = 1

				if (to == 2)( rho = b0[.,(cols(b0)-3)] );;

				Yd    = (-1/rho)*ln((((YM:/Y1):^rho:-1)*delta'):+1)

				MU	  = MU + Yd

				r	  = P*normalden(ln(Y1),MU,SV):/ /*
				*/	   (P*normalden(ln(Y1),MU,SV) + /*
				*/     (1-P)*2*normalden(ln(Y1),MU,S):*normal(-(ln(Y1)-MU)*LAM/S))
				S   = optimize_init()
					  optimize_init_evaluator(S, &fn_zsf_em())
					  optimize_init_argument(S,1,(Y1,YM))
					  optimize_init_argument(S,2,X)
					  optimize_init_argument(S,3,r)
					  optimize_init_argument(S,4,op)
					  optimize_init_params(S, b0)
					  optimize_init_evaluatortype(S,"gf0")
					  optimize_init_which(S,"max" )
					  optimize_init_conv_maxiter(S,maxite)
				b   = optimize(S)
				lk  = optimize_result_value(S)
				tol	= abs(lk - lk0)
				b0	= b
				lk0 = lk
				ite	= ite + 1
			}
		display(" (Zero) Stochastic Frontier. Non-linear model. EM-Algorithm. ")
		}
	  }
	}
 }
if (e1_opt == "nls") {
	V = (1/(rows(Y1)-np))*optimize_result_value(S)*optimize_result_V(S)
}
else {
	V = optimize_result_V(S)
}
if (r_opt != "") (V = optimize_result_V_robust(S))

st_matrix("r(beta)", b)
st_matrix("r(V)", V)
}
end
/******* END ********/
