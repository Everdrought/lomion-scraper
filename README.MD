# Lomion Scraper

This is a scraper designed to scrape all the monsters of the long defunct lomion's
monstrous manual and save it in a easy to access and understand yaml file.
It also contains some basic reading utilities.

Files contain three sets of data

+ Title (name/species/etc)
+ Table (Their stat sheets and alike)
+ Text (Monster description, behaviour, culture...)

## Why
Noone should ever download and organize data of 7600+ monsters and tables by hand

## How
Data is fetched and scraped with nokogiri and httparty, all while concurrent-ruby provides a thread pool so that I don't send hundreds of requests at once since I am trying to be polite while doing it :^\)
Upon running it for the first time, it generates a list of all monsters and a directory called scrap in which it will save all the data about invidual monsters.