defmodule ApprovalWeb.DocumentView do
  use ApprovalWeb, :view
  alias ApprovalWeb.DocumentView

  def render("index.json", %{documents: documents, pagination: pagination}) do
    %{
      data: render_many(documents, DocumentView, "index.json"),
      pageable: %{
        page: pagination.page,
        per_page: pagination.per_page,
        total_count: pagination.total_count
      }
    }
  end

  def render("index.json", %{document: document}) do
    %{
      id: document.id,
      title: document.title,
      content: document.content,
      drafter_id: document.drafter_id,
      drafter_opinion: document.drafter_opinion
    }
  end

  def render("show.json", %{document: document}) do
    %{
      id: document.id,
      title: document.title,
      content: document.content,
      drafterId: document.drafter_id,
      drafterOpinion: document.drafter_opinion,
      createdAt: document.inserted_at,
      approvalLines:
        Enum.map(document.approval_lines, fn approval_line ->
          %{
            sequence: approval_line.sequence,
            approverId: approval_line.approver_id,
            approvalType: approval_line.approval_type,
            opinion: approval_line.opinion,
            receivedAt: approval_line.received_at,
            actedAt: approval_line.acted_at
          }
        end)
    }
  end

  # def render("index.json", %{documents: documents}) do
  #   %{data: render_many(documents, DocumentView, "document.json")}
  # end

  # def render("show.json", %{document: document}) do
  #   %{data: render_one(document, DocumentView, "document.json")}
  # end

  # def render("document.json", %{document: document}) do
  #   %{id: document.id,
  #     title: document.title,
  #     content: document.content,
  #     drafter_id: document.drafter_id,
  #     drafter_opinion: document.drafter_opinion}
  # end
end
