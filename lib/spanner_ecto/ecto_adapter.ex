defmodule SpannerEcto.EctoAdapter do
  use Ecto.Adapters.SQL,
    driver: :spanner_ecto,
    migration_lock: nil

  @impl true
  def supports_ddl_transaction?, do: false
end