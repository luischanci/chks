
## chks

User-written Stata command. Estimation of a non-linear index under sample selection. This is a code in progress.

<a href="https://luischanci.github.io">(Home)</a>

1. To install:
  - From Stata:

    `net install mypoissonch, from(https://luischanci.github.io/chks/) replace`

    - Manual: <a href="https://github.com/luischanci/chks/zipball/master">Download</a>, unzip, and locate all the files into the Stata ado folder (for instance, locate the unzipped ado and other files into `C:\ado\personal\m\`).


2. Examples.

  - General model,

    ![equation](https://latex.codecogs.com/gif.latex?log(y)_{it}=-(1/\rho)*log\left(1&plus;\sum_{m}{\delta_m*y_m}\right)&plus;\mathbf{x}_{it}\mathbf{\beta'}&plus;\epsilon_{it})


      i) Estimation using a NLS approach,

      `chks y1 x1 x2, idx(y2 y3) ces nls`

      ii) if ![equation](https://latex.codecogs.com/gif.latex?\epsilon_{it}=v_{it}-u_{it},&space;with,&space;v_{it}\sim\mathcal{N}(0,\sigma^2_v),&space;and,&space;u_{it}\sim\mathcal{N}^&plus;(0,\sigma^2_u)),

        `chks y1 x1 x2, idx(y2 y3) ces sf`

      iii) in addition to (ii), considering the probability that some $u_{it}=0$ (see the working paper for more detail),

        `chks y1 x1 x2, idx(y2 y3) ces zisf`

    - Other models or possibilities,

      in progress...

<a href="https://luischanci.github.io">Luis Chancí</a>
