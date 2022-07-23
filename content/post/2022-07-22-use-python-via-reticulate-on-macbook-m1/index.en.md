---
title: Use python via reticulate on Macbook M1
author: YUNWEI HU
date: '2022-07-22'
slug: use-python-via-reticulate-on-macbook-m1
categories: []
tags: []
subtitle: ''
summary: ''
authors: []
lastmod: '2022-07-22T23:54:07-07:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---
I stopped updating this blog since 2020 serveral months into the pandemic. When I checked again this week, quite a few things were broken, `hugo`, `shiny` and `latex`, just to name a few. 

I am in the process to repost the old posts, and found that as of today, July 2022, `reticulate` is imcompatible with the `Anacodna` distro, even though Anacodna has a M1 distro since May, 2022. 

The workaround is 
- uninstall `anaconda`
- use `reticulate::install_miniconda`
- Install packages to the `env` of your choice
- then `reticulate::use_miniconda(env)`

It is fairly straightforward. Hopefully reticulate will be compatible with `Anaconda` in future updates. 