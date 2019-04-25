# ReadRepos

ReadRepos is an Simple primary-replica library for Ecto.

## Installation

Add read_repos to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:read_repos, github: "kenta-aktsk/read_repos"}]
end
```

Ensure read_repos is started before your application:

```elixir
def application do
  [applications: [:read_repos]]
end
```

## Usage

Add replica database settings to your `#{Mix.env}.exs` files like below:

```elixir
# config/dev.exs
config :my_app, MyApp.ReadRepo0,
  adapter: Ecto.Adapters.MySQL,
  database: "my_app",
  hostname: "192.168.0.2",
  ...

config :my_app, MyApp.ReadRepo1,
  adapter: Ecto.Adapters.MySQL,
  database: "my_app",
  hostname: "192.168.0.3",
  ...
```

Add supervision tree settings to your application file like below:

```elixir
# lib/my_app.ex
defmodule MyApp do
  use Application

  def start(_type, _args) do
    children = [
      ...
    ]
    # add
    children = children ++ Enum.map(MyApp.Repo.replicas, &supervisor(&1, []))
    ...
  end
end
```

Use ReadRepos in your Repo module like below:

```elixir
# lib/my_app/repo.ex
defmodule MyApp.Repo do
  use Ecto.Repo, otp_app: :my_app
  # add
  use ReadRepos
end
```

Then replica databases can be accessed via `replica` function like below:

```elixir
MyApp.Entry |> MyApp.Repo.replica.all
MyApp.Entry |> MyApp.Repo.replica.get(1)

# you can get all replica repos like below:
MyApp.Repo.replicas
# => [MyApp.ReadRepo0, MyApp.ReadRepo1]

# also you can access each replica repos directly like below:
MyApp.Entry |> MyApp.ReadRepo0.replica.all
```

# Pagination

ReadRepos use [Scrivener](https://github.com/drewolson/scrivener), so you can use `paginate` function like below:

```elixir
# controller
def index(conn, params) do
  page = User |> from |> Repo.replica.paginate(params)
  render(conn, "index.html", users: page.entries, page: page)
end

# template
<%= pagination_links @conn, @page %>
```

You can change `page_size` (default 10) like below:

```elixir
# lib/my_app/repo.ex
defmodule MyApp.Repo do
  use Ecto.Repo, otp_app: :my_app
  use ReadRepos, page_size: 5
end
```


## Specify ReadRepo module name

If you want to use ReadRepo module name other than `ReadRepo`, e.g. `Replica`, you can specify it by regex like below:

```elixir
# config/dev.exs
config :my_app, MyApp.Replica0,
  ...

config :my_app, MyApp.Replica1,
  ...

# lib/my_app/repo.ex
defmodule MyApp.Repo do
  use Ecto.Repo, otp_app: :my_app
  # add
  use ReadRepos, regexp: ~r/.*MyApp.Replica[0-9]+/
end
```

## Remarks

* Replica databases are selected randomly.

* If there are no replica database settings in config file, `MyApp.Repo.replica` returns primary Repo automatically.
