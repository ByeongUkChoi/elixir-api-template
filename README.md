# Elixir API server
## spec
- elixir
- phoenix framework

## run
### application (development)
```
iex -S mix phx.server
```
### database
```
docker run -p 5432:5432 --name postgres -e POSTGRES_PASSWORD=postgres -d postgres
docker exec -it postgres
psql -U postgres
CREATE DATABASE blog_dev;
```

---
## Elixir Project
### install elixir for mac
```
brew install elixir
```
### create project
```
mix new example
```
### complie project
```
mix compile
```
### run project (interactive mode in iex)
```
iex -S mix
```
#### check & call function
```
iex > Application.loaded_applications
iex > ElixirExampleProject.hello
```
### recompile in iex
```
iex > recomple
```
### run project
```
mix run
```

## Phoenix framework Project

### install phoenix
```
mix archive.install hex phx_new
```
### create elixir project (useful for APIs)
```
mix phx.new demo --no-html --no-webpack
```
### run (development)
```
iex -S mix phx.server
```

---

# BlogApp

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
