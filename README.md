# SpannerEcto

## How to use the Google Spanner Library

```elixir
scopes = [
  "https://www.googleapis.com/auth/spanner.admin",
  "https://www.googleapis.com/auth/spanner.data"
]

instance = "projects/epuu-293412/instances/epuu"

{:ok, goth_token} = scopes |> Enum.join(" ") |> Goth.Token.for_scope()

client = GoogleApi.Spanner.V1.Connection.new(goth_token.token)

{:ok, session} = GoogleApi.Spanner.V1.Api.Projects.spanner_projects_instances_databases_sessions_create(client, "#{instance}/databases/epuu_production")

query = %GoogleApi.Spanner.V1.Model.ExecuteSqlRequest{sql: "SELECT * FROM Countries"}

{:ok, result_set} = GoogleApi.Spanner.V1.Api.Projects.spanner_projects_instances_databases_sessions_execute_sql(client, session.name,body: query)
```

## How to use SpannerEcto.Proxy

```elixir
{:ok, pid} = SpannerEcto.Proxy.start_link(project: "epuu-293412", instance: "epuu", database: "epuu_production")

SpannerEcto.Proxy.query(pid, "SELECT * FROM Countries")

```