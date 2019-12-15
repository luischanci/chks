
# chks

User-written Stata command. Nonlinear index and Zero-Inefficiency Stochastic Frontier Model. This code is a beta version and it's been developed for the working paper Chancí, Kumbhakar, and Sandoval, 2019.

<a href="https://luischanci.github.io">(Home)</a>

## Getting Started

1. **Install.** You can choose from one of the following two methods to install:
	- From the Stata command window:

    	`net install chks, from ("https://raw.githubusercontent.com/luischanci/chks/master") replace`

	- Manual installation: <a href="https://github.com/luischanci/chks/zipball/master">Download</a>, unzip, and locate all the files into the Stata ado folder (for instance, locate the unzipped ado and other files into `C:\ado\personal\m\`).

2. **Syntaxis.**

	The general syntaxis is,

    `chks depvariable xregressors, indx(indexvariables) type() estimation() eoption()`

  	where,

	  - `indx()` _varlist_ for the index. `indx()` could be empty, which means that the model is linear rather than a nonlinear index.

	  - `type()`. Functional form for the nonlinear index. There are two types: CES `type(ces)` and Cobb-Douglas `type(cd)`.

	  - `estimation()` is the estimation method: NLS `estimation(nls)`, Stochastic Frontier `estimation(sf)`, or Zero-Stochastic Frontier `estimation(zsf)`.

	  - `eoption()` is the estimation option when estimation is ZSF. It could be Maximum Likelihood Estimation `eoption(ml)` or Expectation-Maximization Algorithm `eoption(em)`. EM is the default option.

	  - `maxitera()` specifies the maximum number of iterations; the default is 500.

3. Models.
	- The general model is one in which a nonlinear index (![formula](https://render.githubusercontent.com/render/math?math=\eta)) is a function of a vector of explanatory variables (**x**) and a residual term (![formula](https://render.githubusercontent.com/render/math?math=\epsilon)):

		![formula](https://render.githubusercontent.com/render/math?math=log(\eta)_{it}=\mathbf{x}_{it}^{'}\mathbf{\beta}+\epsilon_{it})

    	where,

    	![equation](https://latex.codecogs.com/gif.latex?\eta=\left(\sum_{m=1}^M{\delta_mY_m^\rho}\right)^{1/\rho})

    	thus, the equation to estimate is:

    	![equation](https://latex.codecogs.com/gif.latex?log(Y_1)_{it}=-(1/\rho)*log\left(1&plus;\sum_{m\neq1}{\delta_m*(Y_m^{*\rho}-1)}\right)&plus;\mathbf{x}_{it}\mathbf{\beta'}&plus;\epsilon_{it})

    	with ![equation](https://latex.codecogs.com/gif.latex?Y_m^{*}=Y_m/Y_1)

## Using the code.

- Estimation NLS. Let's say that $M=3$ and there are $k$ regressors,

 `chks Y1 x1 x2 ... xk, idx(Y2 Y3) t(ces) es(nls)`

- On the other hand, if the residual is such that ![equation](https://latex.codecogs.com/gif.latex?\epsilon_{it}=v_{it}-u_{it},&space;with,&space;v_{it}\sim\mathcal{N}(0,\sigma^2_v),&space;and,&space;u_{it}\sim\mathcal{N}^&plus;(0,\sigma^2_u)), which is similar to a Nonlinear Stochastic Frontier Model, the command for estimation is:

 `chks Y1 x1 x2 ... xk, idx(Y2 Y3) t(ces) es(sf)`

- Furthermore, if there is a probability that some $u_i=0$, known as **Zero-Inefficiency Stochastic Frontier** model (see Kumbhakar, Parmeter and Tsionas, 2013, "A zero inefficiency stochastic frontier model", in [_Journal of Econometrics_ , 172(1), 66-76](https://doi.org/10.1016/j.jeconom.2012.08.021)), the command would be:

 `chks Y1 x1 x2 ...xk, idx(Y2 Y3) t(ces) es(zsf)`

 In this case there are two additional options: Maximum Likelihood Extimation (add `eo(ml)`) or Expectation-Maximization Algorithm (add `eo(em)`).

- Other models or possibilities are simple variations, such as a Cobb-Douglas index, or linear functions. For instance, a version of a linear Zero-Inefficiency Stochastic Frontier model would be:

    ![equation](https://latex.codecogs.com/gif.latex?y_{it}=\mathbf{x}_{it}\mathbf{\beta'}&plus;\epsilon_{it})

    with ![equation](https://latex.codecogs.com/gif.latex?\epsilon_{it}=v_{it}-u_{it},&space;with,&space;v_{it}\sim\mathcal{N}(0,\sigma^2_v),&space;and,&space;u_{it}\sim\mathcal{N}^&plus;(0,\sigma^2_u)). In this case the command is:

    `chks y1 x1 x2, es(zsf)`

Finally, it is possible to report the robust standard errors (add `robust`) or omit the constant term (add `nocons`).

## Examples.

- **Example 1: A Linear Z-SF.**

	Data (simulation). To illustrate the use of the command, I am going to use a simulation proposed by Diego Restrepo (of course, any mistake would be my responsability). The code for a cost function would be,

	```
	    clear all
		set obs 1000
	    gen x = rnormal()/10
	    gen v = rnormal()/10
	    gen z = rnormal()
	    gentrun double u, left(0)     /* Need module GENTRUN */
	    replace u = u/10              /* u ~ Truncated-left N(0,0.1)*/
	    replace u = 0 if _n > _N-_N/2 /* For a  p=50%, u=0, no inefficiency*/
	    gen 	  e = v - u			  /* For production function (not cost)*/
	    gen 	  y = 1 + x + e
	```

	Command: `chks y x, es(zsf)` for EM-algorithm and `chks y x, es(zsf) eo(ml)` for MLE.

	Results using MLE:

    ```
	    . chks y x, es(zsf) eo(ml)
	    Zero Stochastic Frontier for linear models
	    (ZSF, linear model)
		.
		.
		.
		Iteration 12:  f(p) =  715.46477
		Iteration 13:  f(p) =  715.46477
		 (Zero) Stochastic Frontier, linear model. M.L.E.
		-----------------------------------------------------------------------------------
		                y |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
		------------------+----------------------------------------------------------------
		                x |   1.020781   .0376483    27.11   0.000     .9469912     1.09457
		            _cons |   .9688054   .0050194   193.01   0.000     .9589675    .9786434
		        lnsigma_u |  -1.677142   .3815109    -4.40   0.000    -2.424889   -.9293944
		        lnsigma_v |  -2.170457   .0289882   -74.87   0.000    -2.227272   -2.113641
		logist_probabil~y |   3.404257   1.090584     3.12   0.002     1.266751    5.541763
		-----------------------------------------------------------------------------------
    ```

	Results using EM-algorithm:

    ```
	    . chks y x, es(zsf)
	    Zero Stochastic Frontier for linear models
	    (ZSF, linear model)
		.
		.
		.
		(Zero) Stochastic Frontier, linear model. EM-Algorithm.
	   	-----------------------------------------------------------------------------------
	                   	y |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
	    ------------------+----------------------------------------------------------------
	                   	x |   1.021142   .0367627    27.78   0.000     .9490882    1.093195
	               	_cons |   .9699379   .0036587   265.10   0.000     .9627669    .9771089
	           	lnsigma_u |  -1.775768   .1535916   -11.56   0.000    -2.076802   -1.474734
	           	lnsigma_v |  -2.175327   .0227074   -95.80   0.000    -2.219833   -2.130821
	   	logist_probabil~y |    3.07854   .1541839    19.97   0.000     2.776345    3.380734
	   	-----------------------------------------------------------------------------------
    ```

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

- **Example 4: Non-linear (Index). Zero Stochastic Frontier**.

`chks Y1 x1 x2, indx(Y2 Y3) t(ces) es(zsf) eo(em)`

	```
		------------------------------------------------------------------------------
				Y1 |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
		------------------------------------------------------------------------------
				x1 |   .0155953   .0005609    27.81   0.000      .014496    .0166946
				x2 |   .0392709   .0007659    51.27   0.000     .0377697    .0407721
			     _cons |   2.935441   .0167206   175.56   0.000     2.902669    2.968213
		  		Y2 |   .2252023   .0124254    18.12   0.000     .2008489    .2495557
		  		Y3 |   .5117927   .0132434    38.65   0.000     .4858362    .5377493
		 		rho|   2.293806   .1025533    22.37   0.000     2.092805    2.494807
			 lnsigma_u |  -2.299401   .0789157   -29.14   0.000    -2.454073   -2.144729
			 lnsigma_v |  -2.340403   .0252419   -92.72   0.000    -2.389876    -2.29093
	  	logist_probability |   .5607503   .0657478     8.53   0.000     .4318871    .6896136
		------------------------------------------------------------------------------
	  di 1/(1+exp(-.5607503))
	  0.63662613
	```
------
</br>

Final notes: This is a first draft (or a work in progress). Please provide me with any comment you may have on bugs, wording, inconsistencies, etc.

</br>

### Website

<a href="https://luischanci.github.io/post/chks/">chks</a>

### Author

<a href="https://luischanci.github.io">Luis Chancí</a>

lchanci1@binghamton.edu

Economics, Binghamton University.
