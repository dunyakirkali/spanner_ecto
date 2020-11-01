defmodule SpannerEcto do
  alias SpannerEcto.Query

  def child_spec(opts) do
    DBConnection.child_spec(SpannerEcto.Protocol, opts)
  end

  def execute(conn, query, params, opts) do
    query = %Query{statement: query}
    DBConnection.prepare_execute(conn, query, params, opts)
  end
end
