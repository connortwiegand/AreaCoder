

#leaflet allows for interactive maps, only in Simple Features (sf)
#Choroplethr uses ggplot and data frames converted from shapefiles (sp)

pacman::p_load(rvest, readr, tidyverse, magrittr, data.table)
pacman::p_load(lubridate, zoo)
pacman::p_load(sf, rnaturalearth, rgeos, leaflet)
pacman::p_load(choroplethr, choroplethrAdmin1)
pacman::p_load(stringdist)

# ---------------------------------------------------------------------

### Examples

countries <- ne_countries(returnclass = "sf") %>% st_transform(8857) 

data(admin1.map)
head(admin1.map)
ggplot(admin1.map, aes(long, lat, group=group)) + geom_polygon()

admin1_map("japan")

data(df_japan_census)
df_japan_census$value = df_japan_census$pop_density_km2_2010
admin1_choropleth("japan", df_japan_census)

# ---------------------------------------------------------------------

### Ukraine:

ua_wiki <- read_html(
  "https://en.wikipedia.org/wiki/List_of_dialling_codes_in_Ukraine")
ua_he <- html_elements(ua_wiki, css = "h3 .mw-headline")

#Oblasts:
ua_reg_edit <- html_text2(ua_he) 

Encoding("–")
splits <- str_split(ua_reg_edit, " – ", simplify = T)
ua_df <- data.frame(region = splits[,2], value = splits[,1])


admin_ua <- get_admin1_regions("ukraine")[,2]

admin_spots <- stringdist::amatch(ua_df[,1], admin_ua, maxDist = "8")
copy <- ua_df
copy[,1] <- admin_ua[admin_spots]

missing <- setdiff(admin_ua, copy[,1])
copy[which(copy[,1]  %>% is.na()),1] <- missing

ua_df[,1] <- copy[,1]

copy <- aggregate(cbind(long, lat) ~ region, 
                  data=get_admin1_map("ukraine"),
                  FUN=function(x)mean(range(x)))

copy <- merge(ua_df, copy, by="region")
copy[copy$value==48,]$long %<>% sum(0.5)
copy[copy$value==48,]$lat %<>% sum(0.25)
copy[copy$value==44,]$lat %<>% sum(-0.25)
copy[copy$value==45,]$lat %<>% sum(0.1)
copy[copy$value==45,]$long %<>% sum(-0.1)

ua_df <- copy

ggplot(get_admin1_map("ukraine"), aes(long, lat, color=region)) + 
  geom_path(aes(group=group), show.legend = F) +
  geom_label(data=ua_df, aes(long, lat, label=value, color=region), show.legend = F) +
  ggdark::dark_theme_void()


# ------------------------------------------------------------------------ 
### Peru:
pe_site <- read_html("https://en.wikipedia.org/wiki/Telephone_numbers_in_Peru")

pe_wp <- html_elements(pe_site, css = " .wikitable") #*
wiki_table <- html_table(pe_wp)
pe_df <- wiki_table[[1]]
pe_df %<>% rbind(c(1, "Callao"))
pe_df[1,2] <- "Lima"
for(i in 1:nrow(pe_df)) {
  pe_df[i,2] <- paste0("region de ", tolower(pe_df[i,2])) 
}
pe_df[pe_df[,2]=="region de moquegua",2] <- "departamento de moquegua"
pe_df %<>% rbind(c(1, "provincia de lima")) 
names(pe_df) %<>% tolower()
names(pe_df)[names(pe_df) == "area code"] <- "value"

admin_pe <- get_admin1_regions("peru")[,2]

admin_spots <- stringdist::amatch(unlist(pe_df[,2]), admin_pe, maxDist = "10")

pe_df[,2]%<>% unlist()

copy <- pe_df
copy[,2] <- admin_pe[admin_spots]

#missing <- setdiff(admin_pe, unlist(copy[,2]))
#copy[which(copy[,1]  %>% is.na()),1] <- missing

pe_df[,2] <- copy[,2]

copy <- aggregate(cbind(long, lat) ~ region, 
                  data=get_admin1_map("peru"),
                  FUN=function(x)mean(range(x)))

copy <- merge(pe_df, copy, by="region")
# copy[copy$value==48,]$long %<>% sum(0.5)
# copy[copy$value==48,]$lat %<>% sum(0.25)
# copy[copy$value==44,]$lat %<>% sum(-0.25)
# copy[copy$value==45,]$lat %<>% sum(0.1)
# copy[copy$value==45,]$long %<>% sum(-0.1)

pe_df <- copy

ggplot(get_admin1_map("peru"), aes(long, lat, color=region)) + 
  geom_path(aes(group=group), show.legend = F) +
  geom_label(data=pe_df, aes(long, lat, label=value, color=region), show.legend = F) +
  ggdark::dark_theme_void()
