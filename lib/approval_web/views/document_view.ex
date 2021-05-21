defmodule ApprovalWeb.DocumentView do
  use ApprovalWeb, :view
  alias ApprovalWeb.DocumentView

  def render("index.json", %{documents: documents}) do
    %{data: render_many(documents, DocumentView, "document.json")}
  end

  def render("show.json", %{document: document}) do
    %{data: render_one(document, DocumentView, "document.json")}
  end

  def render("document.json", %{document: document}) do
    %{id: document.id,
      title: document.title,
      content: document.content,
      drafter_id: document.drafter_id,
      drafter_opinion: document.drafter_opinion}
  end
end
