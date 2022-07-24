---
title: Discrete Event Simulation - Part II
author: YUNWEI HU
date: '2022-07-23'
slug: discrete-event-simulation-part-ii
categories:
  - simulation
tags:
  - DES
  - rstats
  - Repairable
subtitle: ''
summary: ''
authors: []
lastmod: '2022-07-23T14:31:16-07:00'
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

This is a repost of the bolg by me dated 2018-05-21.

``` r
#prepare the libraries
library(tidyverse)
library(simmer)
library(simmer.plot)
library(intervals)
```

## Simmer for R

In my short experiment with Simpy and Simmer, Simmer shines in one area: monitoring.
In Simpy a list can be passed to the simulation, and it is flexible to choose what to code.

With Simmer, three commands `get_mon_arrivals()`, `get_mon_attributes()`, `get_mon_resources()` can generate the story book of the simulation. The story is in data.frame format, and can be easily processed in R.

Let’s use the Machine Shop as an Example.

Instead of print out the events in user interface with `log_()`, we make the simulation `invisible`, and add an attribute to log the state (working, fail).

``` r
machine <- function(mttf, repair_time){
      machie <- trajectory() %>% 
      # machine_state: 1-working, 0-fail
      set_attribute("machine_state", 1) %>% 
        timeout(function() rexp(1, 1/mttf)) %>% 
        set_attribute("machine_state", -1, mod="+") %>%
        seize("repairman") %>% 
        timeout(repair_time) %>% 
        release("repairman") %>% 
        set_attribute("machine_state", 1, mod="+") %>% 
        rollback(6)
  } 
plot(machine(10,1))
```

<div id="htmlwidget-1" style="width:672px;height:480px;" class="grViz html-widget"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"diagram":"digraph {\n\ngraph [layout = \"dot\",\n       outputorder = \"edgesfirst\",\n       bgcolor = \"white\"]\n\nnode [fontname = \"sans-serif\",\n      fontsize = \"10\",\n      shape = \"circle\",\n      fixedsize = \"true\",\n      width = \"1.5\",\n      style = \"filled\",\n      fillcolor = \"aliceblue\",\n      color = \"gray70\",\n      fontcolor = \"gray50\"]\n\nedge [fontname = \"Helvetica\",\n     fontsize = \"8\",\n     len = \"1.5\",\n     color = \"gray80\",\n     arrowsize = \"0.5\"]\n\n  \"1\" [label = \"SetAttribute\", shape = \"box\", style = \"solid\", color = \"black\", tooltip = \"keys: [machine_state], values: [1], global: 0, mod: N, init: 0\", fontcolor = \"black\", fillcolor = \"#000000\"] \n  \"2\" [label = \"Timeout\", shape = \"box\", style = \"solid\", color = \"black\", tooltip = \"delay: function()\", fontcolor = \"black\", fillcolor = \"#000000\"] \n  \"3\" [label = \"SetAttribute\", shape = \"box\", style = \"solid\", color = \"black\", tooltip = \"keys: [machine_state], values: [-1], global: 0, mod: +, init: 0\", fontcolor = \"black\", fillcolor = \"#000000\"] \n  \"4\" [label = \"Seize\", shape = \"box\", style = \"filled\", color = \"#7FC97F\", tooltip = \"resource: repairman, amount: 1\", fontcolor = \"black\", fillcolor = \"#7FC97F\"] \n  \"5\" [label = \"Timeout\", shape = \"box\", style = \"solid\", color = \"black\", tooltip = \"delay: 1\", fontcolor = \"black\", fillcolor = \"#000000\"] \n  \"6\" [label = \"Release\", shape = \"box\", style = \"filled\", color = \"#7FC97F\", tooltip = \"resource: repairman, amount: 1\", fontcolor = \"black\", fillcolor = \"#7FC97F\"] \n  \"7\" [label = \"SetAttribute\", shape = \"box\", style = \"solid\", color = \"black\", tooltip = \"keys: [machine_state], values: [1], global: 0, mod: +, init: 0\", fontcolor = \"black\", fillcolor = \"#000000\"] \n  \"8\" [label = \"Rollback\", shape = \"diamond\", style = \"filled\", color = \"lightgrey\", tooltip = \"times: -1\", fontcolor = \"black\", fillcolor = \"#D3D3D3\"] \n\"1\"->\"2\" [color = \"black\", style = \"solid\"] \n\"2\"->\"3\" [color = \"black\", style = \"solid\"] \n\"3\"->\"4\" [color = \"black\", style = \"solid\"] \n\"4\"->\"5\" [color = \"black\", style = \"solid\"] \n\"5\"->\"6\" [color = \"black\", style = \"solid\"] \n\"6\"->\"7\" [color = \"black\", style = \"solid\"] \n\"7\"->\"8\" [color = \"black\", style = \"solid\"] \n\"8\"->\"2\" [color = \"grey\", style = \"dashed\"] \n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>

Make it a function.

``` r
simmer_relia <- function(sim_time, mon_ = "attributes") {
  env <- simmer() %>% 
  # use resource to track system state
  # all items in series will require same "repair" resource. 
  # set capacity to inf, assuming no queue for repair
  # if repair resource busy -> system down
  # for n-oo-k items, if resource server > k-n ->system down 
  add_resource("repairman", capacity = Inf) %>% 
  add_generator("machine_a", machine(100, 10), at(0), mon = 2) %>% 
  add_generator("machine_b", machine(100, 5), at(0), mon = 2) %>% 
  run(sim_time) %>% 
  invisible
  if (mon_=="resources"){
    sim_log <- get_mon_resources(env)
  } else if (mon_=="attributes") {
    sim_log <- get_mon_attributes(env)
  }
  sim_log
}
```

### Loop for replications

``` r
N_RUN <-  10
SIM_END = 500
ptm <- proc.time()
machine_state_log <- 1:N_RUN %>% 
  map_df(function(x) cbind(simmer_relia(SIM_END), tibble(i_run = x)))
simmer_time <- proc.time() - ptm
tail(machine_state_log)
```

    ##         time       name           key value replication i_run
    ## 209 442.3666 machine_b0 machine_state     0           1    10
    ## 210 447.3666 machine_b0 machine_state     1           1    10
    ## 211 462.9960 machine_a0 machine_state     0           1    10
    ## 212 472.8377 machine_b0 machine_state     0           1    10
    ## 213 472.9960 machine_a0 machine_state     1           1    10
    ## 214 477.8377 machine_b0 machine_state     1           1    10

Test

``` r
simu_attributes <- simmer_relia(500)
print(simu_attributes)
```

    ##         time       name           key value replication
    ## 1    0.00000 machine_a0 machine_state     1           1
    ## 2    0.00000 machine_b0 machine_state     1           1
    ## 3   42.28105 machine_b0 machine_state     0           1
    ## 4   47.28105 machine_b0 machine_state     1           1
    ## 5   77.35852 machine_a0 machine_state     0           1
    ## 6   87.35852 machine_a0 machine_state     1           1
    ## 7   98.15019 machine_b0 machine_state     0           1
    ## 8  103.15019 machine_b0 machine_state     1           1
    ## 9  111.34813 machine_a0 machine_state     0           1
    ## 10 121.34813 machine_a0 machine_state     1           1
    ## 11 151.84864 machine_a0 machine_state     0           1
    ## 12 161.84864 machine_a0 machine_state     1           1
    ## 13 179.71953 machine_b0 machine_state     0           1
    ## 14 184.71953 machine_b0 machine_state     1           1
    ## 15 236.37764 machine_b0 machine_state     0           1
    ## 16 241.37764 machine_b0 machine_state     1           1
    ## 17 259.25923 machine_a0 machine_state     0           1
    ## 18 269.25923 machine_a0 machine_state     1           1
    ## 19 397.68679 machine_a0 machine_state     0           1
    ## 20 407.68679 machine_a0 machine_state     1           1

``` r
simu_resources <- simmer_relia(500, mon = "resources")
plot(simu_resources, metric = "usage", "repairman", items = "server", steps = TRUE)
```

<img src="{{< blogdown/postref >}}index.en_files/figure-html/unnamed-chunk-6-1.png" width="672" />

# Monitoring: resources vs attributes

With simmer, by adding user-defined attributes, we can log the simualtion flexibly. In the context of the system reliability, since only one “repariman” resource is requested when ANY of the machines fail, the “repairman” resource can be used directly for simple system reliability metrics. If the it is series system, whenever the repairman is busy, the system is down. Or it is n-out-of-k, then \>= n simultaneous “repairs” implies system down.

The attribute logs the state of all the “machines”, it is more flexible to use the attributes. We are interest in the event sequence of the system down time, the `Intervals` pacakge, which provides a collections of operation on intervals over the real number line (R), is helpful the determine the system state base on the component state.

In the example above, we have the event sequence of the machine_a and machine_b, so for a parellel system, the intersection of downtime interval is the system down time. and for a series system, union.

### Convert event sequences to state intervals

``` r
machine_state_interval <- function(machine_state_log){
  machine_state_log %>%
    group_by(i_run, name) %>% 
    arrange(time) %>% 
    # end_time is lead(start_time) (remove leading NA), last one is sim_end
    mutate(end_time = c(head(lead(time), -1), SIM_END)) %>% 
    ungroup() %>% 
    dplyr::select(name, value, start_time = time, end_time, i_run) %>% 
    arrange(i_run, name, start_time)
}

state_interval <- machine_state_interval(machine_state_log)

machine_down_interval <- function(state_interval, i, machine_name){
  fail_log <- state_interval %>% 
    filter(i_run == i, name == machine_name) %>% 
    filter(value == 0)
  Intervals(matrix(c(fail_log$start_time,fail_log$end_time), ncol = 2))
} 
```

### parallel -\> intersection of the interval

``` r
parallel_down_log <- tibble(start_time = as.numeric(), end_time = as.numeric(), i_run = as.integer())

for (i in 1:N_RUN){
  parallel_down_interval <- interval_intersection(
    machine_down_interval(state_interval, i, "machine_a0"), 
    machine_down_interval(state_interval, i, "machine_b0") )
  if(length(parallel_down_interval) > 0){
    print(i)
    print(parallel_down_interval)
    parallel_down_log <- rbind(parallel_down_log, 
                            cbind(as.matrix(parallel_down_interval), tibble(i_run = i)))
  }
}
```

    ## [1] 2
    ## Object of class Intervals
    ## 1 interval over R:
    ## [478.915332901574, 483.915332901574]
    ## [1] 4
    ## Object of class Intervals
    ## 3 intervals over R:
    ## [127.319955610845, 132.319955610845]
    ## [172.881427812846, 173.262362609792]
    ## [342.919421858134, 345.583527818413]
    ## [1] 8
    ## Object of class Intervals
    ## 2 intervals over R:
    ## [31.0425011441112, 32.3605401348323]
    ## [228.437912753763, 232.337844351521]
    ## [1] 9
    ## Object of class Intervals
    ## 3 intervals over R:
    ## [218.752050740942, 223.752050740942]
    ## [223.757618140727, 225.728760083031]
    ## [392.129864142056, 397.129864142056]
    ## [1] 10
    ## Object of class Intervals
    ## 2 intervals over R:
    ## [177.240104033592, 178.677071282164]
    ## [472.837684197787, 472.99596169469]

``` r
names(parallel_down_log) <- c("start", "end", "i_run")
print(parallel_down_log)
```

    ##       start       end i_run
    ## 1  478.9153 483.91533     2
    ## 2  127.3200 132.31996     4
    ## 3  172.8814 173.26236     4
    ## 4  342.9194 345.58353     4
    ## 5   31.0425  32.36054     8
    ## 6  228.4379 232.33784     8
    ## 7  218.7521 223.75205     9
    ## 8  223.7576 225.72876     9
    ## 9  392.1299 397.12986     9
    ## 10 177.2401 178.67707    10
    ## 11 472.8377 472.99596    10

### Series -\> union of the interval

``` r
series_down_log <- tibble(start_time = as.numeric(), end_time = as.numeric(), i_run = as.integer())

for (i in 1:N_RUN){
  series_down_interval <- interval_union(
    machine_down_interval(state_interval, i, "machine_a0"), 
    machine_down_interval(state_interval, i, "machine_b0") )
  if(length(series_down_interval) > 0){
    series_down_log <- rbind(series_down_log, 
                             cbind(as.matrix(series_down_interval), tibble(i_run = i)))
  }
}
names(series_down_log) <- c("start", "end", "i_run")
head(series_down_log,20)
```

    ##        start       end i_run
    ## 1   16.19063  21.19063     1
    ## 2  129.24719 139.24719     1
    ## 3  185.54990 195.54990     1
    ## 4  238.09241 248.09241     1
    ## 5  286.15305 291.15305     1
    ## 6  329.35981 339.35981     1
    ## 7  394.35776 404.35776     1
    ## 8  430.09741 435.09741     1
    ## 9  442.58259 447.58259     1
    ## 10  24.76090  29.76090     2
    ## 11  36.06396  46.06396     2
    ## 12 168.25193 178.25193     2
    ## 13 297.63221 302.63221     2
    ## 14 312.97773 322.97773     2
    ## 15 345.40873 355.40873     2
    ## 16 413.44466 418.44466     2
    ## 17 477.55216 487.55216     2
    ## 18 495.97379 500.00000     2
    ## 19  30.97991  35.97991     3
    ## 20 189.75923 194.75923     3
