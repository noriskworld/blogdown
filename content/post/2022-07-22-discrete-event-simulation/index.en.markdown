---
title: Discrete Event Simulation
author: YUNWEI HU
date: '2022-07-22'
slug: discrete-event-simulation
categories:
  - simulation
  - Reliability
tags:
  - DES
  - Repairable
  - python
  - rstats
subtitle: ''
summary: ''
authors: []
lastmod: '2022-07-22T21:29:30-07:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

<script src="{{< blogdown/postref >}}index.en_files/htmlwidgets/htmlwidgets.js"></script>
<script src="{{< blogdown/postref >}}index.en_files/viz/viz.js"></script>
<link href="{{< blogdown/postref >}}index.en_files/DiagrammeR-styles/styles.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index.en_files/grViz-binding/grViz.js"></script>

## Discrete Event Simulation (DES) and Reliability Block Diagram (RBD)

Discrete Event Simulation (DES) is the simulation of stochastic processes with discrete state space. An examploe of DES is the classic M/M/1 queue system: exponential interarrival and service times, with a single server. The state space can be defined as the queue length, which is integer-valued and thus “discrete.” This contrasts to, a continuous system, such as simulating a moving object, where state such as location is continuous.

When we are dealing with complex system reliability, we have two dimensions:
- the system reliability hierarchy, which is how component reliability impact the overall system performance
- the dyanmic response to an event, or state change, e.g. component failure, battery drain etc. (ref Yunwei Hu et al. 2022)

System Reliability can be treated a DES problem, if we only consider discrete state of the components and not the continuous parameters. The classic System Reliability theories treat system state space as discrete, and most of the time, binary states.

A reliability block diagram (RBD) is one of the most frequently used tool for modeling system reliability. It use a block diagram method to show how component reliability contributes to the success or failure of a complex system. It is a graphical representation of the boolenan
logic of the system configuration.

Commercial Reliability Software packages, such as Reliasoft Blocksim(R), use Reliability Block Diagram (RBD) to allow users to model the system and then use analytical or simulation methods to calculate the system reliability metrics. Thus, the RBD is used as a graphical interface to build the DES. However, the states are typcially binary, i.e. failure or success. Even though RBD is boolean only, the commercial software has added some dyanmic features, such as phased mission.

In a way, we can say RBD tools focus on the first aspect of the system reliability, and the genric DES tools focus on the second.

If the problem is about how the system design, such as redundancy, will impact the systme reliaiblity, RBD would be the preferred tool. It the problems involve complex dyanmic event sequences, and/or other non-binany system states, a generic DES might be preferred.

## DES in Python and R

DES are implemented in commercial software and also as generic framework in Java, Python, etc. SimPy is a process-based discrete-event simulation framework implemented in Python. More recenlty, Simmer is developed as a process-oriented and trajectory-based Discrete-Event Simulation (DES) package for R. It is designed to be a generic framework like SimPy or SimJulia, and it runs the DES with Rcpp to boost the performance and turning DES in R feasible.

This post aims at evaluating Simpy and Simmer in the context of System Reliability.

## Simpy + Reticulate

`Reticulate` package offers a set of tools for interoperability between Python and R. In this example, we use Reticulate to import a Simpy Model, and pass the simulation result to R as a data frame.

### Machie Shop Example

#### Prepare the python

``` r
library(tidyverse)
library(reticulate)
# use_python("/Users/myhome/anaconda/bin/python")
use_miniconda("base")
source_python("simNHPP.py")
```

### The Simpy Code

See blow:

    import random
    import simpy
    import pandas as pd

    RANDOM_SEED = 42
    MTTF = 100.0                     # Mean time to failure in minutes
    REPAIR_TIME = 2.0               # Time it takes to repair a machine in minutes
    NUM_MACHINES = 1                  # Number of machines in the machine shop
    WEEKS = 4                         # Simulation time in weeks
    SIM_TIME = WEEKS * 7 * 24 * 60    # Simulation time in minutes


    def simNHPP(end_sim):
        event_log = []
        env = simpy.Environment()
        machine_1 = Machine(env, "Machine_1", event_log)
        machine_2 = Machine(env, "Machine_2", event_log)
        env.run(until = end_sim)
        event_log = pd.DataFrame(event_log, columns = ['event','time'])
        return event_log

    def time_to_repair():
        """return time interval until the repair is done, and machine is ready to run again. """
        return REPAIR_TIME

    def time_to_failure():
        """Return time until next failure for a machine.""" 
        return random.expovariate(1.0/MTTF)

    # each machine has a name, and pass the event_log 
    # time to failure and time to repair are defined globally. 
    class Machine:
        def __init__(self, env, name, event_log):
            self.env = env
            self.name = str(name)
            self.work_proc = env.process(self.working(env, event_log))

        def working(self, env, event_log):
            while True:
                # Up until failure
                time_to_fail = time_to_failure()
                # print('%s: time to next failure is %.2f' % (self.name, time_to_fail))
                yield env.timeout(time_to_fail)

                # Repair for time_to_repair
                # print("%s Failure Starts at %.2f" % (self.name, env.now))
                event_log.append([self.name + " fails", env.now])
                repair_time = time_to_repair()
                yield env.timeout(repair_time)
                # print("%s is repaired at %.2f" % (self.name, env.now))
                event_log.append([self.name + " fixed", env.now])

### Simulation

``` r
ptm <- proc.time()
ev <- 1:1000 %>% 
  map_df(function(x) cbind(simNHPP(SIM_TIME), tibble(n_run = x)))
map_time <- proc.time() - ptm
print(map_time)
```

    ##    user  system elapsed 
    ##  14.887   0.142  15.048

``` r
head(ev)
```

    ##             event      time n_run
    ## 1 Machine_1 fails  59.32455     1
    ## 2 Machine_1 fixed  61.32455     1
    ## 3 Machine_2 fails  90.35233     1
    ## 4 Machine_2 fixed  92.35233     1
    ## 5 Machine_1 fails 165.67622     1
    ## 6 Machine_1 fixed 167.67622     1

## R-simmer

R-simmer has similar implentation as Simpy, but with Simmer, everything is monitored automatically, and reported in handy data frames. This works especially well when doing many replications.

### Prepare enviroment

``` r
library(tidyverse)
library(simmer)
library(simmer.plot)
```

### Define Machine

``` r
machine <- function(mttf, repair_time, print_log = TRUE){
  if (print_log) {
      machie <- trajectory() %>% 
        set_attribute("n_fail", 0) %>% 
        timeout(function() rexp(1, 1/mttf)) %>% 
        log_("fail") %>% 
        set_attribute("n_fail", 1, mod="+") %>%
        seize("repairman") %>% 
        timeout(repair_time) %>% 
        release("repairman") %>% 
        log_("fixed") %>% 
        rollback(7)
  } else {
      machine <- trajectory() %>% 
        set_attribute("n_fail", 0) %>% 
        timeout(function() rexp(1, 1/mttf)) %>% 
        set_attribute("n_fail", 1, mod="+") %>%
        seize("repairman") %>% 
        timeout(repair_time) %>% 
        release("repairman") %>% 
        rollback(5)
    
  }

}
plot(machine(10,1))
```

<div id="htmlwidget-1" style="width:672px;height:480px;" class="grViz html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"diagram":"digraph {\n\ngraph [layout = \"dot\",\n       outputorder = \"edgesfirst\",\n       bgcolor = \"white\"]\n\nnode [fontname = \"sans-serif\",\n      fontsize = \"10\",\n      shape = \"circle\",\n      fixedsize = \"true\",\n      width = \"1.5\",\n      style = \"filled\",\n      fillcolor = \"aliceblue\",\n      color = \"gray70\",\n      fontcolor = \"gray50\"]\n\nedge [fontname = \"Helvetica\",\n     fontsize = \"8\",\n     len = \"1.5\",\n     color = \"gray80\",\n     arrowsize = \"0.5\"]\n\n  \"1\" [label = \"SetAttribute\", shape = \"box\", style = \"solid\", color = \"black\", tooltip = \"keys: [n_fail], values: [0], global: 0, mod: N, init: 0\", fontcolor = \"black\", fillcolor = \"#000000\"] \n  \"2\" [label = \"Timeout\", shape = \"box\", style = \"solid\", color = \"black\", tooltip = \"delay: function()\", fontcolor = \"black\", fillcolor = \"#000000\"] \n  \"3\" [label = \"Log\", shape = \"box\", style = \"solid\", color = \"black\", tooltip = \"message: fail, level: 0\", fontcolor = \"black\", fillcolor = \"#000000\"] \n  \"4\" [label = \"SetAttribute\", shape = \"box\", style = \"solid\", color = \"black\", tooltip = \"keys: [n_fail], values: [1], global: 0, mod: +, init: 0\", fontcolor = \"black\", fillcolor = \"#000000\"] \n  \"5\" [label = \"Seize\", shape = \"box\", style = \"filled\", color = \"#7FC97F\", tooltip = \"resource: repairman, amount: 1\", fontcolor = \"black\", fillcolor = \"#7FC97F\"] \n  \"6\" [label = \"Timeout\", shape = \"box\", style = \"solid\", color = \"black\", tooltip = \"delay: 1\", fontcolor = \"black\", fillcolor = \"#000000\"] \n  \"7\" [label = \"Release\", shape = \"box\", style = \"filled\", color = \"#7FC97F\", tooltip = \"resource: repairman, amount: 1\", fontcolor = \"black\", fillcolor = \"#7FC97F\"] \n  \"8\" [label = \"Log\", shape = \"box\", style = \"solid\", color = \"black\", tooltip = \"message: fixed, level: 0\", fontcolor = \"black\", fillcolor = \"#000000\"] \n  \"9\" [label = \"Rollback\", shape = \"diamond\", style = \"filled\", color = \"lightgrey\", tooltip = \"times: -1\", fontcolor = \"black\", fillcolor = \"#D3D3D3\"] \n\"1\"->\"2\" [color = \"black\", style = \"solid\"] \n\"2\"->\"3\" [color = \"black\", style = \"solid\"] \n\"3\"->\"4\" [color = \"black\", style = \"solid\"] \n\"4\"->\"5\" [color = \"black\", style = \"solid\"] \n\"5\"->\"6\" [color = \"black\", style = \"solid\"] \n\"6\"->\"7\" [color = \"black\", style = \"solid\"] \n\"7\"->\"8\" [color = \"black\", style = \"solid\"] \n\"8\"->\"9\" [color = \"black\", style = \"solid\"] \n\"9\"->\"2\" [color = \"grey\", style = \"dashed\"] \n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

``` r
simmer_relia <- function(sim_time, print_log = T) {
  env <- simmer() %>% 
  # use resource to track system state
  # all items in series will require same "repair" resource. 
  # set capacity to inf, assuming no queue for repair
  # if repair resource busy -> system down
  # for n-oo-k items, if resource server > k-n ->system down 
  add_resource("repairman", capacity = Inf) %>% 
  add_generator("machine_a", machine(100, 1, print_log), at(0), mon = 2) %>% 
  add_generator("machine_b", machine(100, 1, print_log), at(0), mon = 2) %>% 
  run(sim_time)
  repair_log <- get_mon_resources(env)
}
```

Plot the repair_log

``` r
# n_fail <- get_mon_attributes(env)
repair_log <- simmer_relia(100)
```

    ## 12.1535: machine_b0: fail
    ## 13.1535: machine_b0: fixed
    ## 38.7201: machine_b0: fail
    ## 39.7201: machine_b0: fixed

``` r
plot(repair_log, metric = "usage", "repairman", items = "server", steps = TRUE)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-6-1.png" width="672" />

Calculate System Downtime, assuming in series.

``` r
repair_log <- repair_log %>% 
  mutate(duration = c(diff(time),0)) %>% 
  # assuming series, any item down -> system down
  mutate(sys_state = if_else(server > 0, 0, 1) ) %>%
  dplyr::rename(state_start = time) 

downtime <- repair_log %>% 
  group_by(sys_state) %>% 
  summarise(duration = sum(duration)) 
print(downtime)
```

    ## # A tibble: 2 × 2
    ##   sys_state duration
    ##       <dbl>    <dbl>
    ## 1         0      2  
    ## 2         1     25.6

### loop

``` r
ptm <- proc.time()
repair_log <- 1:1000 %>% 
  map_df(function(x) cbind(simmer_relia(SIM_TIME, F), tibble(n_run = x)))
simmer_time <- proc.time() - ptm
print(simmer_time)
```

    ##    user  system elapsed 
    ##  12.782   0.188  13.011

``` r
tail(repair_log)
```

    ##          resource     time server queue capacity queue_size system limit
    ## 1595807 repairman 40271.97      1     0      Inf        Inf      1   Inf
    ## 1595808 repairman 40272.97      0     0      Inf        Inf      0   Inf
    ## 1595809 repairman 40280.60      1     0      Inf        Inf      1   Inf
    ## 1595810 repairman 40281.60      0     0      Inf        Inf      0   Inf
    ## 1595811 repairman 40307.81      1     0      Inf        Inf      1   Inf
    ## 1595812 repairman 40308.81      0     0      Inf        Inf      0   Inf
    ##         replication n_run
    ## 1595807           1  1000
    ## 1595808           1  1000
    ## 1595809           1  1000
    ## 1595810           1  1000
    ## 1595811           1  1000
    ## 1595812           1  1000

## Appendix: Types of Simulation

A good summary on this topic can be found at [Simulation and Modelling to Understand Change by *Manuele Leonelli*](https://bookdown.org/manuele_leonelli/SimBook/types-of-simulations.html)
Without quoting the whole chapter, I will only highlight the key elements:
- Stochastic vs. deterministic
- Static vs. Dynamic
- (Among dynamic simulations) Discrete vs. Continuous

``` mermaid
graph TD;
    Simulation--> Stochastic;
    Simulation--> Deterministic;
    Stochastic--> Dynamic;
    Stochastic--> Static;
    Dynamic--> Discrete;
    Dynamic--> Continuous;
```

## Reference

1.  Yunwei Hu, Tarannom Parhizkar, Ali Mosleh (2022). Guided simulation for dynamic probabilistic risk assessment of complex systems: Concept, method, and application. In *Reliability Engineering & System Safety*, January 2022

2.  Modarres, Mohammad; Mark Kaminskiy; Vasiliy Krivtsov (1999). Reliability Engineering and Risk Analysis. Ney York, NY: Marcel Decker, Inc. p. 198. ISBN 0-8247-2000-8.
