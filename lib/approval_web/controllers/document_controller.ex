defmodule ApprovalWeb.DocumentController do
  use ApprovalWeb, :controller

  alias Approval.Documents
  alias Approval.Documents.Document

  alias Approval.Repo
  alias Approval.Documents.Queries.DocumentIndexQuery

  action_fallback ApprovalWeb.FallbackController

  def index(conn, _params) do
    documents = DocumentIndexQuery.new() |> Repo.all()
    render(json conn, documents)
    # documents = Documents.list_documents()
    # render(conn, "index.json", documents: documents)
  end

  def show(conn, %{"id" => id}) do
    document = Documents.get_document!(id)
    render(conn, "show.json", document: document)
  end

  # TODO: draft document
  # def draft(conn, %{"document" => document_params}) do
  def draft(conn, _params) do
    render(json conn, "TODO:")
  end

  def create(conn, %{"document" => document_params}) do
    with {:ok, %Document{} = document} <- Documents.create_document(document_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.document_path(conn, :show, document))
      |> render("show.json", document: document)
    end
  end

  def update(conn, %{"id" => id, "document" => document_params}) do
    document = Documents.get_document!(id)

    with {:ok, %Document{} = document} <- Documents.update_document(document, document_params) do
      render(conn, "show.json", document: document)
    end
  end

  def delete(conn, %{"id" => id}) do
    document = Documents.get_document!(id)

    with {:ok, %Document{}} <- Documents.delete_document(document) do
      send_resp(conn, :no_content, "")
    end
  end
end
