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
Compatible with Ruby >= 3.2. See `.tool-versions` for the current development version.

### PostgreSQL 
Some queries are PostgreSQL-specific.

### Redis
Redis is used in production for caching.

## Demo

For a quick demo in Docker, run:

```bash
docker compose up --build
```

In a new terminal run the migrations:

```bash
docker compose exec backend bin/rake db:migrate
```

Seed the DB:

```bash
docker compose exec backend bin/rake db:seed
```

The app will be available at http://localhost:3005. 

Login credentials: username `admin`, password `admin`.

Database is exposed on port `5499`.

## ARM64 issue with Cyrillic

* https://github.com/jgarber/redcloth/issues/91

## License

Copyright (c) 2007–2024 Vitalii Khustochka
