defmodule ApprovalWeb.DocumentController do
  use ApprovalWeb, :controller

  alias Approval.Documents
  alias Approval.Documents.Document

  action_fallback ApprovalWeb.FallbackController

  def index(conn, params) do
    {documents, pagination} = Documents.get_document_list(params)
    render(conn, "index.json", documents: documents, pagination: pagination)
  end

  def show(conn, %{"id" => id}) do
    document = Documents.get_document_with_approval_lines(id)
    render(conn, "show.json", document: document)
  end

  def draft(conn, params) do
    {:ok, document} = Documents.draft_document(params)

    conn
    |> put_status(:created)
    |> show(%{"id" => document.id})
  end

  def approve(conn, params) do
    approver_id = get_req_header(conn, "x-user-id") |> hd |> String.to_integer()

    case params["approve_type"] do
      "confirm" -> Documents.confirm(params["id"], approver_id, params["opinion"])
      "reject" -> Documents.reject(params["id"], approver_id, params["opinion"])
      "pending" -> Documents.pending(params["id"], approver_id)
      _ -> :error
    end

    send_resp(conn, :ok, "success")
  end

  ############## 기본 함수
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
end
