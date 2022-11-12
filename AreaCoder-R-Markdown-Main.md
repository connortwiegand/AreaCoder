---
title: "AreaCoder"
author: "Connor Wiegand"
date: "11 November 2022"
output:
  html_document:
    theme: yeti
    highlight: haddock
    toc: yes
    toc_depth: 4
    toc_float: yes
    keep_md: yes
  pdf_document:
    toc: yes
    toc_depth: '4'
always_allow_html: true
---



## Background


## Loading Packages

- Leaflet allows for interactive maps, only in Simple Features (sf)
- Choroplethr uses ggplot and data frames converted from shapefiles (sp)\


```r
## Load your packages here, e.g.
pacman::p_load(rvest, readr, tidyverse, magrittr, data.table)
pacman::p_load(lubridate, zoo)
pacman::p_load(sf, rnaturalearth, rgeos, leaflet)
pacman::p_load(choroplethr, choroplethrAdmin1)
```


## 1) Read in the data


```r
m100 = read_html("http://www.alltime-athletics.com/m_100ok.htm")
m100_wp <- html_element(m100, xpath = '/html/body/center[3]/pre/text()[1]')
```


## 2) Proof of Concept

Let's start by trying Peru, which can also be found in section 3.1.

### 2-1: Get Telephone Data

Let's start by pulling the area code data that we need from wikipedia:

#### 2-1-0: Read website


```r
wiki_site <- read_html("https://en.wikipedia.org/wiki/Telephone_numbers_in_Peru")
```

#### 2-1-1: Scrape for Desired data; format said data
For this, one must copy the xpath via inspect element by hand. In this example, using just the table body (no headers) is what works. This still reads and preserves the headers.

One large challenge for the future is ** *how to automate this?* **

```r
wiki_xpath <- '/html/body/div[3]/div[3]/div[5]/div[1]/table[2]/tbody'
## Here, using just the table body (no headers) is what works
### headers are still preserved


wiki_wp <- html_element(wiki_site, xpath = wiki_xpath) #*
wiki_table <- html_table(wiki_wp)
```

So there that is...

## 2-2: Get Regions of Peru
countries <- ne_countries(returnclass = "sf") %>% st_transform(8857) 

data(admin1.map)
head(admin1.map)
ggplot(admin1.map, aes(long, lat, group=group)) + geom_polygon()

admin1_map("japan")

data(df_japan_census)
df_japan_census$value = df_japan_census$pop_density_km2_2010
admin1_choropleth("japan", df_japan_census)


## 3) Individual Phone Number Maps
Below, you can find an organized list of area code maps done by hand. This list also includes any sources which are in and of themselves complete, in the sense of having an easily-accessible (preferably Wikipedia-based) area code map: 









