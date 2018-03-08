---
title: Bye, Atom! (for now)
author: Yunwei Hu
date: '2018-03-07'
slug: bye-atom-for-now
categories: []
tags: [rstats, pandas, text editor]
---
I have heard a lot of good things about [Atom](https://github.com/atom) from GitHub. It boasts a large library of [packages](https://atom.io/packages).

My need is simple, R and Python coding for data analysis and some manipulation of text files as needed. Markdown is my latest favorite for writing notes to myself.

Atom is powerful, but not a lightweight as Notepad++, so it is always slower to start up and more difficult for me to go through the menus. The last straw came yesterday, when I tried to manipuate some csv files. 
Notepad++ outperformed Atom. 

- Notepad++ autodect the encoding as UTF-16-LE, and Atom failed to do so. 
- To save the file as UTF-8, Atom has nice package to do so, and Notepad++ need a CRTL+A and copy paste. 
- Atom totally failed when I tried to open a larger csv (200M). It just crashed. Notepad++ not only opened file fairly quickly, and it did not sweat during CRTL+A and copy paste routuine. 

For my user case, I will use Rstudio + Spyder/Jupyter for coding, and Notepad++ for text file manipulations. Do not really see a niche for Atom to shine, for now. 

See you, I barely know you, Atom. Hope we will meet again soon!

A non-trival side note, this happened when I failed to read a Spotfire exported csv in R and Python. Until I noticed that Notepad++ detected the encoding as UTF-16. The default of Sportfire is exporting in UTF-16. I am waiting for corporate IT to figure out a way to add option to export as UTF-8. `Python/Pandas` can read UTF-16 but my favorite `R/readr` cannot handle UTF-16 yet, even though it is filed as an [issue](https://github.com/tidyverse/readr/issues/306).
The workaround is to use Notepad++ or Python/Pandas to convert the csv files to UTF-8. I hope `readr` can be updated soon to resolve it. 