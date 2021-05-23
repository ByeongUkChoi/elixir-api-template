defmodule ApprovalWeb.DocumentView do
  use ApprovalWeb, :view
  alias ApprovalWeb.DocumentView

  # TODO: page
  def render("index.json", %{documents: documents}) do
    %{data: render_many(documents, DocumentView, "document.json"),
    pageable: %{page: 0, size: 20, total: 30}}
  end

  def render("show.json", %{document: document}) do
    %{
      id: document.id,
      title: document.title,
      content: document.content,
      drafterId: document.drafter_id,
      drafterOpinion: "help",
      createdAt: "2021-05-22 12:00:00",
      approveLines: Enum.map(document.approve_lines, fn(approve_line) -> %{
        sequence: approve_line.sequence,
        approverId: approve_line.approver_id,
        approveType: approve_line.approve_type,
        opinion: approve_line.opinion,
        receivedAt: approve_line.received_at,
        actedAt: approve_line.acted_at
      } end)
    }
  end

  # def render("index.json", %{documents: documents}) do
  #   %{data: render_many(documents, DocumentView, "document.json")}
  # end

  # def render("show.json", %{document: document}) do
  #   %{data: render_one(document, DocumentView, "document.json")}
  # end

  def render("document.json", %{document: document}) do
    %{id: document.id,
      title: document.title,
      content: document.content,
      drafter_id: document.drafter_id,
      drafter_opinion: document.drafter_opinion}
  end
end
