
## chks

User-written Stata command. Estimation of a non-linear index under sample selection. This is a code under construction for the working paper Chancí, Kumbhakar, and Sandoval, 2019.

<a href="https://luischanci.github.io">(Home)</a>

1. To install:
  - From Stata:

    `net install chks, from(https://luischanci.github.io/chks/) replace`

    - Manual installation: <a href="https://github.com/luischanci/chks/zipball/master">Download</a>, unzip, and locate all the files into the Stata ado folder (for instance, locate the unzipped ado and other files into `C:\ado\personal\m\`).

2. Syntaxis.
  - The general syntaxis is,

  `chks depvariable xregressors, indx(indxvariables) type() estimation() eoption()`

  where,
    - `indx()` contains the varlist that forms the index, excluding one variable (Y1). indx() could be empty, which means it is a linear model rather than an idex.
    - `type()` is the type of nonlinear index. There are two possibilities: CES `type(ces)` and Cobb-Douglas `type(cd)`.
    - `estimation()` is the estimation method: NLS `estimation(nls)`, Stochastic Frontier `estimation(sf)`, or Zero-Stochastic Frontier `estimation(zsf)`.
    - `eoption()` is the estimation option when estimation is ZSF. It could be Maximum Likelihood Estimation `eoption(ml)` or Expectation-Maximization Algorithm `eoption(em)`. EM is the default option.

3. Models.

  - The general model is one in which a non-linear index ![equation](https://latex.codecogs.com/gif.latex?\eta) is a function of a vector of explanatory variables **x** and a residual component ![equation](https://latex.codecogs.com/gif.latex?\epsilon):

    ![equation](https://latex.codecogs.com/gif.latex?log(\eta)_{it}=\mathbf{x}_{it}\mathbf{\beta'}&plus;\epsilon_{it})

    where, for instance, there are three variables that form the index (could be M variables):

    ![equation](https://latex.codecogs.com/gif.latex?\eta=\left(\sum_{m=1}^3{\delta_mY_m^\rho}\right)^{1/\rho})

    thus, the equation to estimate is:

    ![equation](https://latex.codecogs.com/gif.latex?log(Y_1)_{it}=-(1/\rho)*log\left(1&plus;\sum_{m\neq1}{\delta_m*(Y_m^{*\rho}-1)}\right)&plus;\mathbf{x}_{it}\mathbf{\beta'}&plus;\epsilon_{it})

    with ![equation](https://latex.codecogs.com/gif.latex?Y_m^{*}=Y_m/Y_1)

      i) Estimation using a NLS approach,

      `chks Y1 x1 x2, idx(Y2 Y3) t(ces) es(nls)`

      ii) On the other hand, if the residual is such that ![equation](https://latex.codecogs.com/gif.latex?\epsilon_{it}=v_{it}-u_{it},&space;with,&space;v_{it}\sim\mathcal{N}(0,\sigma^2_v),&space;and,&space;u_{it}\sim\mathcal{N}^&plus;(0,\sigma^2_u)), which is similar to a Nonlinear Stochastic Frontier Model, the command for estimation is:

      `chks Y1 x1 x2, idx(Y2 Y3) t(ces) es(sf)`

      iii) Finally, if additionally to (ii), there is a probability that some ![equation](https://latex.codecogs.com/gif.latex?u_{it}=0) (see for instance, Kumbhakar, Parmeter and Tsionas, 2013, **"A zero inefficiency stochastic frontier model"**, in _Journal of Econometrics_ , 172(1), 66-76), the command is:

      `chks Y1 x1 x2, idx(y2 y3) t(ces) es(zsf)`

      In this case there are two additional options for the estimation: Maximum Likelihood (add `eo(ml)`) or EM-Algorithm (add `eo(em)`).

  - Other models or possibilities include simple variations, such as a Cobb-Douglas index, or other even more simple linear functions. For instance, a simpler version of a Zero-Inefficiency Stochastic Frontier is:

    ![equation](https://latex.codecogs.com/gif.latex?y_{it}=\mathbf{x}_{it}\mathbf{\beta'}&plus;\epsilon_{it})

    with ![equation](https://latex.codecogs.com/gif.latex?\epsilon_{it}=v_{it}-u_{it},&space;with,&space;v_{it}\sim\mathcal{N}(0,\sigma^2_v),&space;and,&space;u_{it}\sim\mathcal{N}^&plus;(0,\sigma^2_u)). In this case the command is:

    `chks y1 x1 x2, es(zsf)`

  In any case, it is also possible to report the robust standard errors (add `robust`) or to omit the constant (add `nocons`).

4. Examples.
  - Linear model (ZISF).
    - Simulate the data. To warm up, I am going to use a simulation proposed by <a href="http://www.eafit.edu.co/docentes-investigadores/Paginas/diego-restrepo.aspx">Diego Restrepo</a> (of course, any mistake is my responsability).

    ```
    clear all
    gen x = rnormal()/10
    gen v = rnormal()/10
    gen z = rnormal()
    gentrun double u, left(0)		   /* Need module GENTRUN */
    replace u = u/10 				       /* u ~ Truncated-left N(0,0.1)*/
    replace u = 0 if _n > _N-_N/2	 /* For a  p=50%, u=0, no inefficiency*/
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
    Iteration 0:   f(p) = -236.69929
    Iteration 1:   f(p) =  79.142406
    Iteration 2:   f(p) =  144.23055
    Iteration 3:   f(p) =  149.85904
    Iteration 4:   f(p) =  150.04607
    Iteration 5:   f(p) =  150.04816
    Iteration 6:   f(p) =  150.04816
    Iteration 0:   f(p) = -236.69929
    Iteration 1:   f(p) =  79.142406
    Iteration 2:   f(p) =  144.23055
    Iteration 3:   f(p) =  149.85904
    Iteration 4:   f(p) =  150.04607
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
    . chks yD xD, es(zsf) eo(ml)
    Zero Stochastic Frontier for linear models
    (ZSF, linear model)
    Iteration 0:   f(p) = -14.388102  (not concave)
    Iteration 1:   f(p) =  365.23572  (not concave)
    Iteration 2:   f(p) =  373.16491  (not concave)
    Iteration 3:   f(p) =  374.85774
    Iteration 4:   f(p) =  375.08149
    Iteration 5:   f(p) =  375.09279
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

-----

Author
---
<a href="https://luischanci.github.io">Luis Chancí</a>

lchanci1@binghamton.edu

Economics, Binghamton University.
