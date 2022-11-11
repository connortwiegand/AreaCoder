

#leaflet allows for interactive maps, only in Simple Features (sf)
#Choroplethr uses ggplot and data frames converted from shapefiles (sp)

pacman::p_load(rvest, readr, tidyverse, magrittr, data.table)
pacman::p_load(lubridate, zoo)
pacman::p_load(sf, rnaturalearth, rgeos, leaflet)
pacman::p_load(choroplethr, choroplethrAdmin1)

# ---------------------------------------------------------------------

### Longer Remarks:

#* Also may need to try the following, in general (see assignment):
#wiki_text <- html_text(wiki_wp)
#substr(wiki_text, 1, 1000)

# ---------------------------------------------------------------------

# 1. Start by trying Peru:
## (a) Get data:

wiki_site <- read_html("https://en.wikipedia.org/wiki/Telephone_numbers_in_Peru")

# Have to copy the xpath via inspect element 
## How to automate in general?
###
wiki_xpath <- '/html/body/div[3]/div[3]/div[5]/div[1]/table[2]/tbody'
## Here, using just the table body (no headers) is what works
### headers are still preserved

wiki_wp <- html_element(wiki_site, xpath = wiki_xpath) #*
wiki_table <- html_table(wiki_wp)

#So there that is...

# -----------------

##(b) get regions of Peru
countries <- ne_countries(returnclass = "sf") %>% st_transform(8857) 

data(admin1.map)
head(admin1.map)
ggplot(admin1.map, aes(long, lat, group=group)) + geom_polygon()

admin1_map("japan")

data(df_japan_census)
df_japan_census$value = df_japan_census$pop_density_km2_2010
admin1_choropleth("japan", df_japan_census)



# centered at input data for low distortion
