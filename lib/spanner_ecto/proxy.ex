defmodule SpannerEcto.Proxy do
  use GenServer

  @scopes [
    "https://www.googleapis.com/auth/spanner.admin",
    "https://www.googleapis.com/auth/spanner.data"
  ]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def stop(pid) do
    GenServer.stop(pid, :normal)
  end

  def query(pid, statement) do
    GenServer.call(pid, {:query, statement})
  end

  defp get_token() do
    @scopes
    |> Enum.join(" ")
    |> Goth.Token.for_scope()
  end

  defp get_database(opts) do
    [
      "projects",
      Keyword.get(opts, :project),
      "instances",
      Keyword.get(opts, :instance),
      "databases",
      Keyword.get(opts, :database)
    ]
    |> Enum.join("/")
  end

  defp get_session(client, opts) do
    GoogleApi.Spanner.V1.Api.Projects.spanner_projects_instances_databases_sessions_create(
      client,
      get_database(opts)
    )
  end

  # Server

  @impl true
  def init(opts) do
    {:ok, goth_token} = get_token()
    client = GoogleApi.Spanner.V1.Connection.new(goth_token.token)
    {:ok, session} = get_session(client, opts)

    {:ok, {client, session}}
  end

  @impl true
  def terminate(_, {client, session}) do
    GoogleApi.Spanner.V1.Api.Projects.spanner_projects_instances_databases_sessions_delete(
      client,
      session.name
    )
  end

  @impl true
  def handle_call({:query, statement}, _, {client, session}) do
    query = %GoogleApi.Spanner.V1.Model.ExecuteSqlRequest{sql: statement}

    {:ok, result_set} =
      GoogleApi.Spanner.V1.Api.Projects.spanner_projects_instances_databases_sessions_execute_sql(
        client,
        session.name,
        body: query
      )

    {
      :reply,
      result_set,
      {client, session}
    }
  end
end
