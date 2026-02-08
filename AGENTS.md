# Quails - AI Agent Guidelines

## Project Overview

Quails is a Ruby on Rails application for tracking and sharing birdwatching activities. Users can log observations, map locations, attach photos, generate life/year/region lists, and write blog posts about birding adventures.

## Tech Stack

- **Framework**: Rails 8.1 (modular gems, not full rails gem)
- **Ruby**: >= 3.2
- **Database**: PostgreSQL (required, some queries are PG-specific)
- **Cache**: Redis (production)
- **Background Jobs**: GoodJob
- **Frontend**: Sprockets + jsbundling-rails, jQuery, Bootstrap, HAML templates
- **Testing**: Minitest, Capybara, Playwright (system tests)
- **Styling**: SCSS (some use SASS)

## Project Structure

```
app/
  cells/           # View components (year progress, summary)
  channels/        # ActionCable channels (eBird imports)
  controllers/     # Standard Rails + API namespace
  decorators/      # Decorator pattern for models
  formatters/      # Text formatting (wiki, paragraphs)
  helpers/         # View helpers
  jobs/            # Background jobs
  mailers/         # Email delivery
  models/          # ActiveRecord models + POROs
  views/           # HAML templates

lib/
  ebird/           # eBird integration
  export/          # Data export utilities
  quails/          # Core application modules
  tasks/           # Rake tasks

test/
  controllers/     # Controller tests
  models/          # Model tests
  system/          # Playwright-based JS tests
  integration/     # Integration tests
  factories/       # FactoryBot factories
```

## Key Domain Models

- **Card**: An observation checklist for a specific date/location
- **Observation**: Individual bird sighting (belongs to Card and Species)
- **Species**: Bird species with taxonomy
- **Taxon**: Taxonomic classification
- **Locus**: Geographic location (hierarchical via ancestry gem)
- **Post**: Blog posts about birding
- **Image/Video/Media**: Attached media files
- **EbirdTaxon**: eBird taxonomy integration

## Development Commands

```bash
# Start database
docker compose up -d

# Setup (install deps, create/migrate DB)
bin/setup

# Run development server
bin/dev

# Run tests
bin/rails test:all                    # All tests
bin/rails test test/models/       # Model tests only
bin/rails test:system     # System tests (requires Playwright)

# Linting
bundle exec rubocop
# bundle exec haml-lint app/views

# Database
bin/rails db:migrate
bin/rails db:seed
```

## Coding Conventions

### Ruby/Rails

- Use `frozen_string_literal: true` pragma
- Follow RuboCop rules (see `.rubocop.yml`)
- Use HAML for views (not ERB)
- Use `simple_form` for forms
- Use `kaminari` for pagination
- Prefer scopes and query objects over complex controller logic

### Models

- Use `ApplicationRecord` as base class
- Validations go at the top of the model
- Use `acts_as_list` for orderable items
- Use `ancestry` for hierarchical data (Locus)

### Controllers

- RESTful actions preferred
- Use concerns for shared behavior (`AdministrativeConcern`, `LocalizationConcern`)
- Use decorators for view-specific logic

### Testing

- Use FactoryBot for test data
- System tests use Playwright via `capybara-playwright-driver`
- Test file naming: `*_test.rb`
- Use `rails-controller-testing` for controller specs

## External Integrations

- **Flickr**: Photo management (`flickraw-cached`)
- **eBird**: Observation import/export
- **LiveJournal**: Blog cross-posting
- **AWS S3**: File storage (ActiveStorage)
- **Honeybadger**: Error monitoring

## Environment Variables

Key variables (see `.env.TEMPLATE`):
- Database configuration
- Redis URL
- AWS credentials (S3)
- Flickr API keys
- Honeybadger API key

## Important Notes

1. **PostgreSQL Required**: Don't use SQLite; some queries use PG-specific features
2. **HAML Templates**: All views use HAML, not ERB
3. **Modular Rails**: Individual Rails components are loaded separately (not the full `rails` gem)
4. **Localization**: App supports multiple locales (see `config/locales/`)
5. **Image Processing**: Uses `image_processing` gem for variants
6. **Page Caching**: Uses `actionpack-page_caching` for static pages

## Common Patterns

### Decorators
```ruby
# Instead of helpers, use decorators for model presentation
class CardDecorator < ModelDecorator
  def formatted_date
    observ_date.strftime("%B %d, %Y")
  end
end
```

### Lifelists
```ruby
# Various lifelist strategies in app/models/lifelist/
Lifelist::Advanced
  .over(params.permit(:year, :month, :day, :locus, :motorless, :exclude_heard_only))
  .sort(params[:sort])
```

### Search
```ruby
# Search classes in app/models/search/
Search::SpeciesSearch.new(query).find
```

## File Locations

- Routes: `config/routes.rb`
- Database schema: `db/schema.rb`
- Initializers: `config/initializers/`
- Rake tasks: `lib/tasks/`
- Test helpers: `test/test_helper.rb`
