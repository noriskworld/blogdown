---
title: Shiny app in responsive iframe
author: ''
date: '2018-03-20'
slug: shiny-app-in-iframe
categories:
tags:
  - webapp
  - rstats
---
## Interactive Plot in Blogdown

Shiny apps and Blogdown could be the game changer, and R is no longer just a niche language for quick data modeling. R/Rstudio is becoming a platform for data scientist to do all his or her work. A data scientist with not much experience with building a website, like me, can use Shiny + Blogdown to produce a (almost-)professional personal webiste. 

## Create a Shiny app and deploy it
Shiny apps can’t be run client-side like javascript can. And they can’t be deployed on a standard webserver. Shiny apps need to be hosted on a server with R and shiny installed and connected to a running R process.  

Following the example by [Paul Campbell](https://www.cultureofinsight.com/blog/2018/03/15/2018-03-15-responsive-iframes-for-shiny-apps/), we updated the Shiny app with 

- one js script sourced in the shiny app UI

```
tags$head(
      tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
                  type="text/javascript")
      ),
```
- A tagged placeholder div at the point in the app you want to be ‘end’ (after all the charts and tables) in UI

```
HTML('<div data-iframe-height></div>')
```
Then, add the following to the Rmarkdown:

- another js script sourced in the parent HTML page
- some iframe styling
- the iframe itself
- a final script telling iframeResizer to go to work on our iframe and look for the tagged <div>

```
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.min.js"></script>
<style>
  iframe {
    min-width: 100%;
  }
</style>
<iframe id="myIframe" src="https://riskpredictions.shinyapps.io/prob_plot/" scrolling="no" frameborder="no"></iframe>
<script>
  iFrameResize({
    heightCalculationMethod: 'taggedElement'
  });
</script>
```


<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.min.js"></script>
<style>
  iframe {
    min-width: 100%;
  }
</style>
<iframe id="myIframe" src="https://riskpredictions.shinyapps.io/prob_plot/" scrolling="no" frameborder="no"></iframe>
<script>
  iFrameResize({
    heightCalculationMethod: 'taggedElement'
  });
</script>

Ok, now we have a resizable iframe. However, Shiny apps use fluid output as default, so that the size of sidebar, relative to the main panel, cannot be changed. 