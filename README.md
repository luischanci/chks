
## chks

User-written Stata command. Estimation of a non-linear index under sample selection.

1. To install:
  - Directly from stata:

    `net install mypoissonch, from(https://luischanci.github.io/mypoissonch/) replace`

    - Manual: <a href="https://github.com/luischanci/mypoissonch/zipball/master">Download Files</a>, unzip, and locate all the files into the Stata ado folder path (for instance, locate the unzipped ado and other files into `C:\ado\personal\m\`).

2. Examples.

  - General model,

    ![equation](https://latex.codecogs.com/gif.latex?log(y)_{it}=-(1/\rho)*log\left(1&plus;\sum_{m}{\delta_m*y_m}\right)&plus;\mathbf{x}_{it}\mathbf{\beta'}&plus;\epsilon_{it})

    <!--- This generates a link:
    <a href="https://www.codecogs.com/eqnedit.php?latex=log(y)_{it}=-(1/\rho)log\(1&plus;\sum_{m}{\delta_m*y_m}\)&plus;x_{it}\beta&plus;\epsilon_{it}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?log(y)_{it}=-(1/\rho)log\(1&plus;\sum_{m}{\delta_m*y_m}\)&plus;x_{it}\beta&plus;\epsilon_{it}" title="log(y)_{it}=-(1/\rho)log\(1+\sum_{m}{\delta_m*y_m}\)+x_{it}\beta+\epsilon_{it}" /></a>
    -->

      i) using a basic NLS approach,

      iii) if ![equation](https://latex.codecogs.com/gif.latex?\epsilon_{it}=v_{it}-u_{it}), ![equation]('https://latex.codecogs.com/gif.latex?v_{it}\sim \mathcal{N}(0,\sigma^2_v)'), and ![equation](https://latex.codecogs.com/gif.latex?u_{it}\sim \mathcal{N}^+(0,\sigma^2_u)),



    - a more simple version,


    - Other possibilities,


<a href="https://luischanci.github.io">Luis Chancí</a>
