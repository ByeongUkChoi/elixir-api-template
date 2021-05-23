defmodule Approval.Documents.Queries.DocumentIndexQuery do
  import Ecto.Query
  alias Approval.Documents.Document

  def new() do
    from d in Document,
    select: %{id: d.id,
    title: d.title,
    content: d.content,
    drafterId: d.drafter_id,
    drafterOpinion: d.drafter_opinion
  }
  end
end
