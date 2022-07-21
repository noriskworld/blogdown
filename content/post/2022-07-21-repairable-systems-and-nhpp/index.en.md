---
title: Repairable Systems and NHPP
author: Yunwei Hu
date: '2022-07-21'
slug: repairable-systems-and-nhpp
categories: []
tags: []
subtitle: ''
summary: ''
authors: []
lastmod: '2022-07-21T00:33:07-07:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

## Probabilistic Models for Repairable Systerms
When analyzing repairable systems, areas of interest may include assessing the expected number of failures during the warranty period, maintaining a minimum mission reliability, evaluating the rate of wearout, determining when to replace or overhaul a system and minimizing life cycle costs. 

When the downtime of the repairable systems are short, the **point processes** are often the model of choice. A point process gives:

* **N(t)**: a counting function that keeps track of the *cumulative number of failures* a given system has had from time zero to time t. N(t) is a step function that jumps up one every time a failure occurs and stays at the new level until the next failure.
* M(t) = **E[N(t)]** : the expected number (average number) of cumulative failures by time t for these systems.
* The Repair Rate (the Rate Of Occurrence Of Failures, or **ROCOF**) is the mean rate of failures per unit time. Mathematically, it is derivative of M(t), denoted m(t). It is also called intensity function in theory of random process.


## Power Law NHPP and Underlying Weibull
The NHPP model is has a model for minimal repair, where the repair of a failed system is just enough to get the system operational again. In Power Law NHPP, the time to first failure follows the Weibull distribution, then each succeeding failure is governed by the model as in the case of minimal repair. 

For Power Law NHPP model, the expected number of failures in the first t hours, M(t), is:
$$E\left[ N(t) \right] =\lambda\cdot t^\beta$$
where $\lambda,\beta>0$.
The probability that the number of failures, N(t), is:
$$Pr\left[ N \left( t \right)= n \right]=\frac{\left( \lambda \cdot t^\beta \right) \cdot e^{-\lambda \cdot t^\beta}} {n!}  ;n=0,1,2,...   $$
 
The repair rate (or ROCOF) for this model is
$$ m(t)=\lambda\cdot \beta \cdot t^{\beta−1}$$
where $\lambda>0,\beta > 0$.

For a Power Law NHPP process, the time to the first fail follows a Weibull distribution with shape parameter $\beta$ and characteristic life $\eta=\left( \lambda \right) ^ {- \frac {1} {\beta}}$. The accumulated Hazard function:
$$H\left(t \right)=\lambda\cdot t^\beta$$
Culmative Distribution Function
$$F\left( t \right) = 1-e^{-\lambda \cdot t^\beta}$$



Other names for the Power Law model are: the **Duane Model** and the **AMSAA model**. AMSAA stands for the United States Army Materials System Analysis Activity, where much theoretical work describing the Power Law model was performed in the 1970's.

## NHPP and the Underlying Weibull time-to-failure 
The reliability function always follows
$$R\left( t \right)=1-F\left( t \right) = e^{-H\left( t \right)}$$
and
$$ H\left( t \right) = -\ln\left[ R\left( t \right) \right]=-\ln \left[ 1-F\left( t \right) \right]$$


### As bad as old

![types_of_repairs](type_of_repairs.png)



### Meaning of $\beta$
When $\beta=1$, it becomes a HPP model, where $m(t)=\lambda$.  

$E \left[ N \left( t \right) \right] =\lambda\cdot T$, is just a straight line, and the slope is $\beta$.


### todo
insert plots of m(t), M(t) when beta = 0.5, 1, 2, 4

 
## Reference
1. NHPP http://www.itl.nist.gov/div898/handbook/apr/section1/apr172.htm
1. Weibull http://www.itl.nist.gov/div898/handbook/apr/section1/apr162.htm
1. Power Law RGA http://www.weibull.com/hotwire/issue131/relbasics131.htm
1. Reliasoft NHPP http://reliawiki.org/index.php/Crow-AMSAA_(NHPP)
1. https://stats.stackexchange.com/questions/49012/how-to-estimate-poisson-process-using-r-or-how-to-use-nhpoisson-package
1. Repairable Systems  http://www.itl.nist.gov/div898/handbook/apr/section1/apr125.htm
1. Marvin Rausand, Arnljot Høyland; System Reliability Theory: Models, Statistical Methods, and Applications, 2nd Edition
1. Mohammad Modarres - Reliability Engineering and Risk Analysis: A Practical Guide, Second Edition (2nd Edition) (8/23/09)

