
# chks

User-written Stata command. Nonlinear index and Zero-Inefficiency Stochastic Frontier Model. This code is a beta version and it's been developed for the working paper Chancí, Kumbhakar, and Sandoval, 2019.

<a href="https://luischanci.github.io">(Home)</a>

## Getting Started

1. **Install.** You can choose from one of the following two methods to install:
	- From the Stata command window:

    	`net install chks, from(https://luischanci.github.io/chks/) replace`

	- Manual installation: <a href="https://github.com/luischanci/chks/zipball/master">Download</a>, unzip, and locate all the files into the Stata ado folder (for instance, locate the unzipped ado and other files into `C:\ado\personal\m\`).

2. **Syntaxis.**

	The general syntaxis is,

    `chks depvariable xregressors, indx(indexvariables) type() estimation() eoption()`

  	where,

	  - `indx()` _varlist_ for the index. `indx()` could be empty, which means that the model is linear rather than a nonlinear index.

	  - `type()`. Functional form for the nonlinear index. There are two types: CES `type(ces)` and Cobb-Douglas `type(cd)`.

	  - `estimation()` is the estimation method: NLS `estimation(nls)`, Stochastic Frontier `estimation(sf)`, or Zero-Stochastic Frontier `estimation(zsf)`.

	  - `eoption()` is the estimation option when estimation is ZSF. It could be Maximum Likelihood Estimation `eoption(ml)` or Expectation-Maximization Algorithm `eoption(em)`. EM is the default option.


3. Models.
	- The general model is one in which a nonlinear index ![equation](https://latex.codecogs.com/gif.latex?\eta) is a function of a vector of explanatory variables **x** and a residual component ![equation](https://latex.codecogs.com/gif.latex?\epsilon):

    	![equation](https://latex.codecogs.com/gif.latex?log(\eta)_{it}=\mathbf{x}_{it}\mathbf{\beta'}&plus;\epsilon_{it})

    where, for instance, there are three variables that form the index (could be M variables):

    ![equation](https://latex.codecogs.com/gif.latex?\eta=\left(\sum_{m=1}^M{\delta_mY_m^\rho}\right)^{1/\rho})

    thus, the equation to estimate is:

    ![equation](https://latex.codecogs.com/gif.latex?log(Y_1)_{it}=-(1/\rho)*log\left(1&plus;\sum_{m\neq1}{\delta_m*(Y_m^{*\rho}-1)}\right)&plus;\mathbf{x}_{it}\mathbf{\beta'}&plus;\epsilon_{it})

    with ![equation](https://latex.codecogs.com/gif.latex?Y_m^{*}=Y_m/Y_1)

	i. Estimation NLS,

    	`chks Y1 x1 x2 ... xk, idx(Y2 Y3) t(ces) es(nls)`

    ii. On the other hand, if the residual is such that ![equation](https://latex.codecogs.com/gif.latex?\epsilon_{it}=v_{it}-u_{it},&space;with,&space;v_{it}\sim\mathcal{N}(0,\sigma^2_v),&space;and,&space;u_{it}\sim\mathcal{N}^&plus;(0,\sigma^2_u)), which is similar to a Nonlinear Stochastic Frontier Model, the command for estimation is:

    	`chks Y1 x1 x2 ... xk, idx(Y2 Y3) t(ces) es(sf)`

    iii. Finally, if additionally to (ii), there is a probability that some ![equation](https://latex.codecogs.com/gif.latex?u_{it}=0) (see for instance, Kumbhakar, Parmeter and Tsionas, 2013, **"A zero inefficiency stochastic frontier model"**, in _Journal of Econometrics_ , 172(1), 66-76), the command would be:

    	`chks Y1 x1 x2 ...xk, idx(Y2 Y3) t(ces) es(zsf)`

    In this case there are two additional options: Maximum Likelihood Extimation (add `eo(ml)`) or Expectation-Maximization Algorithm (add `eo(em)`).

  - Other models or possibilities are simple variations, such as a Cobb-Douglas index, or linear functions. For instance, a version of a linear Zero-Inefficiency Stochastic Frontier model would be:

    ![equation](https://latex.codecogs.com/gif.latex?y_{it}=\mathbf{x}_{it}\mathbf{\beta'}&plus;\epsilon_{it})

    with ![equation](https://latex.codecogs.com/gif.latex?\epsilon_{it}=v_{it}-u_{it},&space;with,&space;v_{it}\sim\mathcal{N}(0,\sigma^2_v),&space;and,&space;u_{it}\sim\mathcal{N}^&plus;(0,\sigma^2_u)). In this case the command is:

    `chks y1 x1 x2, es(zsf)`

	In any case, it is also possible to report the robust standard errors (add `robust`) or omit the constant term (add `nocons`).

4. Examples.

 - Example 1: **Linear model (ZISF)**.
    - Data (simulation).

      To illustrate the use of the command, I am going to use first a simulation proposed by Diego Restrepo (of course, any mistake would be my responsability).

    ```
    clear all
    gen x = rnormal()/10
    gen v = rnormal()/10
    gen z = rnormal()
    gentrun double u, left(0)     /* Need module GENTRUN */
    replace u = u/10              /* u ~ Truncated-left N(0,0.1)*/
    replace u = 0 if _n > _N-_N/2 /* For a  p=50%, u=0, no inefficiency*/
    gen 	  e = v + u
    gen 	  y = 1 + x + e
    ```

    - Command:

      `chks y x, es(zsf)`

      or

      `chks y x, es(zsf) eo(ml)`

    - Results using EM-algorithm:

    ```
    . chks y x, es(zsf)
    Zero Stochastic Frontier for linear models
    (ZSF, linear model)

    Iteration 5:   f(p) =  150.04816
    Iteration 6:   f(p) =  150.04816
    (Zero) Stochastic Frontier, linear model. Estimation EM-Algorithm.
    -----------------------------------------------------------------------------------
                   yD |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    ------------------+----------------------------------------------------------------
                   xD |    1.02164   .0517391    19.75   0.000     .9202334    1.123047
                _cons |   1.057753   .0055784   189.61   0.000      1.04682    1.068687
            lnsigma_u |   -3.71969   .6994031    -5.32   0.000    -5.090494   -2.348885
            lnsigma_v |  -2.166826   .0317456   -68.26   0.000    -2.229046   -2.104606
    logit_probability |   1.627449   .1207253    13.48   0.000     1.390832    1.864066
    -----------------------------------------------------------------------------------
    ```

    - Results using MLE:

    ```
    . chks y x, es(zsf) eo(ml)
    Zero Stochastic Frontier for linear models
    (ZSF, linear model)

    Iteration 6:   f(p) =  375.09283
    Iteration 7:   f(p) =  375.09283
    (Zero) Stochastic Frontier, linear model. M.L.E.
    -----------------------------------------------------------------------------------
                   yD |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    ------------------+----------------------------------------------------------------
                   xD |     1.0212   .0515218    19.82   0.000     .9202194    1.122181
                _cons |   1.036664   .0175377    59.11   0.000     1.002291    1.071037
            lnsigma_u |  -2.115596   .3437051    -6.16   0.000    -2.789246   -1.441947
            lnsigma_v |  -2.263115   .0683824   -33.09   0.000    -2.397142   -2.129088
    logit_probability |   1.475334   1.507923     0.98   0.328    -1.480141    4.430808
    -----------------------------------------------------------------------------------
    ```

	thus, the estimated probability would be: `di 1/(1+exp(-1.4))=0.8`

 - Example 2: **Non-linear index**.

    ```
    use https://luischanci.github.io/chks/chksdata1, clear
    chks Y1 x1 x2, indx(Y2 Y3) es(nls) t(ces) r

    Iteration 16:  f(p) =  12.058803
    ------------------------------------------------------------------------------
              Y1 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
              x1 |   .0158278   .0006196    25.54   0.000     .0146134    .0170422
              x2 |   .0401204   .0008423    47.63   0.000     .0384695    .0417712
           _cons |   2.894777   .0180462   160.41   0.000     2.859407    2.930146
              Y2 |    .225702    .012979    17.39   0.000     .2002636    .2511403
              Y3 |   .5136438   .0136537    37.62   0.000     .4868831    .5404046
             rho |   2.301384   .1146792    20.07   0.000     2.076617    2.526151
    ------------------------------------------------------------------------------
    ```

    In this particular example, in which there is a nonlinear function without additional especifications in the residual component, similar results can be obtained using NLS in Stata:

    ```
		g  ly1 = ln(Y1)
		g  ry2 = Y2/Y1
		g  ry3 = Y3/Y1

    	nl (ly1 = -(1/{rho = 0.5})*ln( 1 + 			 		///
						  	{delta2 = 0.3}*(ry2^{rho}-1) +  ///
						  	{delta3 = 0.3}*(ry3^{rho}-1) )  ///
						    + ({b0}+{b1}*x1+{b2}*x2) ), r

		Iteration 6:  residual SS =   12.0588
		Iteration 7:  residual SS =   12.0588


		Nonlinear regression                                Number of obs =      1,000
		                                                    R-squared     =     0.9839
		                                                    Adj R-squared =     0.9838
		                                                    Root MSE      =   .1101435
		                                                    Res. dev.     =  -1580.083

		------------------------------------------------------------------------------
		             |               Robust
		         ly1 |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
		-------------+----------------------------------------------------------------
		        /rho |   2.301383   .1085109    21.21   0.000     2.088447     2.51432
		     /delta2 |    .225702   .0124839    18.08   0.000     .2012041    .2501999
		     /delta3 |   .5136438   .0134125    38.30   0.000     .4873237    .5399639
		         /b0 |   2.894777   .0180631   160.26   0.000      2.85933    2.930223
		         /b1 |   .0158278   .0006212    25.48   0.000     .0146087    .0170469
		         /b2 |   .0401204   .0008432    47.58   0.000     .0384657     .041775
		------------------------------------------------------------------------------
	  Parameter b0 taken as constant term in model
    ```

 - Example 3: **Non-linear (Index) Stochastic Frontier**.

	```
    chks Y1 x1 x2, indx(Y2 Y3) es(sf) t(ces) r
	Iteration 34:  f(p) =  793.27611
      ------------------------------------------------------------------------------
          	    Y1 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
	  -------------+----------------------------------------------------------------
          	    x1 |   .0155817   .0006264    24.87   0.000      .014354    .0168095
          	    x2 |   .0392952   .0009681    40.59   0.000     .0373978    .0411925
             _cons |   2.993987   .0264685   113.11   0.000      2.94211    3.045865
                Y2 |   .2249359   .0125398    17.94   0.000     .2003583    .2495134
                Y3 |   .5125146   .0132849    38.58   0.000     .4864766    .5385526
               rho |   2.296911   .1106526    20.76   0.000     2.080036    2.513786
         lnsigma_u |  -2.206232   .1435049   -15.37   0.000    -2.487496   -1.924967
         lnsigma_v |  -2.435302   .0812527   -29.97   0.000    -2.594555    -2.27605
	  ------------------------------------------------------------------------------
	```

 - Example 4: **Non-linear (Index). Zero Stochastic Frontier**.

	`chks Y1 x1 x2, indx(Y2 Y3) t(ces) es(zsf) eo(em)`

	```
	------------------------------------------------------------------------------------
					Y1 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
	-------------------+----------------------------------------------------------------
					x1 |   .0155953   .0005609    27.81   0.000      .014496    .0166946
					x2 |   .0392709   .0007659    51.27   0.000     .0377697    .0407721
				 _cons |   2.935441   .0167206   175.56   0.000     2.902669    2.968213
					Y2 |   .2252023   .0124254    18.12   0.000     .2008489    .2495557
					Y3 |   .5117927   .0132434    38.65   0.000     .4858362    .5377493
				   rho |   2.293806   .1025533    22.37   0.000     2.092805    2.494807
			 lnsigma_u |  -2.299401   .0789157   -29.14   0.000    -2.454073   -2.144729
			 lnsigma_v |  -2.340403   .0252419   -92.72   0.000    -2.389876    -2.29093
	logist_probability |   .5607503   .0657478     8.53   0.000     .4318871    .6896136
	------------------------------------------------------------------------------------
	di 1/(1+exp(-.5607503))
	0.63662613
	```
------
</br>

Final notes: This is a first draft (still in progress). Please provide me with any comments you may have on bugs, wording, inconsistencies, etc.

</br>

### Author

<a href="https://luischanci.github.io">Luis Chancí</a>

lchanci1@binghamton.edu

Economics, Binghamton University.
