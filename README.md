# Quails

This is an application for keeping track of birdwatching activities and sharing them with the world. It allows to
log bird observations, place them on the map, attach images, generate life-, year- or region lists,
and blog about birds and birding.

## Why the name

**Quails** is a collective name for several groups of mid-sized hen-like birds. The reference species is the Old World
**Common Quail** _Coturnix coturnix_. Moreover, it rhymes with Rails, the name of the web framework. 

In fact, 'rails' is a bird name too. It refers to the members of the 
_Rallidae_ family, associated mostly with wetlands.

## Dependencies

### Ruby 
Compatible with Ruby >= 3. See `.tool-versions` for the current development version.

### PostgreSQL 
Some queries are PostgreSQL-specific.

### Redis
Redis is used in production for caching and by Resque for background jobs

## License

Copyright (c) 2007–2024 Vitalii Khustochka
