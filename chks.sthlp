{smcl}
{* *! version 1.2 June2019}{...}
{hline}
help for {hi:chks}
{hline}
{viewerjumpto "Description" "chks##description"}{...}
{viewerjumpto "Syntax" "mchks##syntax"}{...}
{viewerjumpto "Options" "chks##options"}{...}
{viewerjumpto "Citation" "chks##citation"}{...}
{viewerjumpto "Description" "chks##description"}{...}
{viewerjumpto "Stored Values" "chks##return"}{...}
{viewerjumpto "Examples" "chks##examples"}{...}
{viewerjumpto "References" "chks##references"}{...}
{viewerjumpto "Author" "chks##author"}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p 4 8}{cmd:chks} {hline 2} Estimation of Linear / Non-linear Zero-Stochastic Frontier Models.{p_end}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{p 4 4 2}{cmd:chks} User-written Stata command. Estimation of a non-linear index under sample selection. This is a code under construction for a working paper.

{p 4 12 2}For more information, 
visit: {browse "http://luischanci.github.io/chks"} {p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:chks} {depvar} {indepvars} {ifin} [{it:weight}]
[{cmd:,}
 {cmdab:in:dx(}
 {varlist}{cmd:)}
 {cmdab:t:ype()}
 {cmdab:es:timation()}
 {cmdab:eo:ption()}
 {cmdab:nonc:onstant}
 {cmdab:r:obust}
 {cmdab:maxi:tera(#)}
]

{marker options}{...}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Nonlinear Model}
{synopt :{opth in:dx(varlist)}}contains the varlist that forms the index, excluding one variable (Y1). indx() could be empty, which means it is a linear model rather than an index.{p_end}

{syntab:Functional Form}
{synopt :{opt t:ype(function)}}{it:function} may be Cobb-Douglas ({opt cd}) or CES ({opt ces}){p_end}

{syntab:Estimation}
{synopt :{opt es:timation(method)}}{it:method} may be Nonlinear Least Squares ({opt nls}), Stochastic Frontier ({opt sf}), or Zero-Stochastic Frontier ({opt zsf}).{p_end}

{synopt :{opt eo:ption()}} additional estimation specification when estimation method is ZSF. It could be Maximum Likelihood Estimation ({opt ml}) or Expectation-Maximization Algorithm ({opt em}). EM is the default option.{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt r:obust}.{p_end}

{syntab:Constant}
{synopt :{opt nocon:stant}}suppress constant term.{p_end}

{syntab:Optimization}
{synopt :{opt maxi:tera(#)}}specifies the maximum number of iterations; the default is 500.{p_end}

{synoptset 28 tabbed}{...}

{marker citation}{...}
{title:Citation}

{p 4 8 2}{cmd:chks} is not an official Stata command.
It is a free contribution to the research community.
Please cite it as such: {p_end}
{p 8 8 2}Chancí, L. 2019. chks command. Estimation of linear and non-linear (zero) stochastic frontier models. {it: Mimeo}.{p_end}


{marker return}{...}
{title:Return values}

{col 4}Matrices

{col 8}{cmd:r(betas)}{col 27}Coefficient vector
{col 8}{cmd:e(V)}{col 27}Variance-covariance matrix


{marker examples}{...}
{title:Examples}

{p 4 8 2}{stata "use https://luischanci.github.io/chks/chksdata1, clear"}{p_end}
{p 4 8 2}{stata "chks Y1 x1 x2, indx(Y2 Y3) es(nls) t(ces) r"}{p_end}

{p 4 8 2}{stata "use https://luischanci.github.io/chks/chksdata1, clear"}{p_end}
{p 4 8 2}{stata "chks Y1 x1 x2, indx(Y2 Y3) t(ces) es(zsf) eo(em)"}{p_end}


{marker references}{...}
{title:References}


{marker K2013}{...}
{phang}
Kumbhakar, Parmeter, and Tsionas. 2013.
{browse "https://doi.org/10.1016/j.jeconom.2012.08.021":A zero inefficiency stochastic frontier model.}
{it:Journal of Econometrics, 175(1),66-76}{p_end}


{marker author}{...}
{title:Author}

{p 4}Luis Chancí,{p_end}
{p 4}Binghamton University, NY.{p_end}
{p 4}website: {browse "http://luischanci.github.io":http://luischanci.github.io}{p_end}
{p 4}email:{browse "mailto:lchanci1@binghamton.edu":lchanci1@binghamton.edu}.{p_end}

{title:Also see}
{p 4 13 2} Online: help for {help ml}, {help mata}.
