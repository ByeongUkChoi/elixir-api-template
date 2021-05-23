defmodule Approval.Documents.Queries.DocumentIndexQuery do
  import Ecto.Query
  alias Approval.Documents.Document

  def new() do
    from d in Document
  end
end
