---
title: That annoying space
author: Yunwei Hu
date: '2018-03-10'
slug: that-annoying-space
categories: []
tags:
  - python
  - Jupyter
  - JSON
  - Jupiter json
---
Another sleepless night wasting hours chasing a little bug. 

I was trying to paste a `Jupyter Notebook` from one computer to another. The route I choose is to use the Apple Notes to share the source code. After I paste the source code in text editor and save as "ipynb", Jupyter does not recognize it as a JSON. 

First thing I found out, `gmail` is the workaround. Just paste into gmail, and remove the format, and copy+paste, then it works. Same steps in text editors does not work. Huh ...

Trouble shooting, using comparing tool, the processed by gmail file and the directly pasted file looks exact same to my naked eyes, but marked as diffent. Next step, HEX. 

The diffence is "A0" vs "20"!

There it is, non-breaking space vs. regular space. 

Use the regex in Atom to replace all `\xa0' did the trick. It is a JSON now!

The topic was [discussed](https://github.com/mikechambers/as3corelib/issues/110) before, the acceptable white spaces in JSON include:
<<<<<<< HEAD
> ws = *( </br>
%x20 / ; Space </br>
%x09 / ; Horizontal tab </br>
%x0A / ; Line feed or New line </br>
%x0D ; Carriage return </br>
=======
> ws = *(
%x20 / ; Space
%x09 / ; Horizontal tab
%x0A / ; Line feed or New line
%x0D ; Carriage return
>>>>>>> 4fdf5b98f71d543d442e11f322750c5d6a1ff941
)

Hours not well spent ...