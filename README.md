
## chks

User-written Stata command. Estimation of a non-linear index under sample selection. This is a code under construction for the working paper Chancí, Kumbhakar, and Sandoval, 2019.

<a href="https://luischanci.github.io">(Home)</a>

1. To install:
  - From Stata:

    `net install chks, from(https://luischanci.github.io/chks/) replace`

    - Manual: <a href="https://github.com/luischanci/chks/zipball/master">Download</a>, unzip, and locate all the files into the Stata ado folder (for instance, locate the unzipped ado and other files into `C:\ado\personal\m\`).


2. Example.

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

      In this case there are two additonal options for the estimation: Maximum Likelihood (add `eo(ml)`) or EM-Algorithm (add `eo(em)`).

  - Other models or possibilities include simple variations, such as a Cobb-Douglas index, or other even more simple linear functions. For instance, a simpler version of a Zero-Inneficiency Stochastic Frontier is:

    ![equation](https://latex.codecogs.com/gif.latex?y_{it}=\mathbf{x}_{it}\mathbf{\beta'}&plus;\epsilon_{it})

    with ![equation](https://latex.codecogs.com/gif.latex?\epsilon_{it}=v_{it}-u_{it},&space;with,&space;v_{it}\sim\mathcal{N}(0,\sigma^2_v),&space;and,&space;u_{it}\sim\mathcal{N}^&plus;(0,\sigma^2_u)). In this case the command is:

    `chks y1 x1 x2, es(zsf)`

In any cases is possible to report the robust standar errors (add `robust`) or ommit the constant (add `nocons`).

-----

<a href="https://luischanci.github.io">Luis Chancí</a>
