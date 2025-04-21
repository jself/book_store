# BookStore

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

There is already an account to test with, demo@demo.com and Testing12345

The mailbox is live at http://localhost:4000/dev/mailbox
The system will not send mails in dev mode, and I didn't connect an SMTP for it.

## Implementation Notes

  * This is using sqlite3, so there shouldn't be any extra database setup
  * Cart is handled in cart_helper.ex, and cart_service.ex 
  * Email is in book_store/email.ex
  * Listing view is listing.ex, Detail detail.ex
  * Used generators for most of context, other than the filter_books, search_books, search_authors, convert_to_order, add_to_cart, etc, but customized from there
  * Used the auth generator for login/registration with some changes
  
## Things I would change

  * Adding better testing, ran out of time
  * I'd like the cart to be more self-contained, maybe with a using macro to inject the handle_infos or something, maybe load it in book_store_web.ex rather than having to handle it in each liveview
  * SQLite's text searching is rather limited, possibly try to use the FTS plugin, or more likely use postgres full text or ElasticSearch. If we were adding facets, I'd probably go something along the ElasticSearch route after some research..
  * Skipped payments obviously
  * Picture fields, facets, short descriptions, ISBNs, publication dates, etc. Lots of missing data

## General Notes
  
  * AI generated the initial designs of the html templates and the email, as well as the seed data
  * I wrote most of the rest of the elixir code that wasn't pre-generated
  * AI generated docs and tests, I fixed the tests
