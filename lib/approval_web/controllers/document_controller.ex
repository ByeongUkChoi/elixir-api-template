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
    with %Document{} = document <- Documents.get_document_with_approval_lines(id) do
      render(conn, "show.json", document: document)
    else
      nil -> {:error, :not_found}
    end
  end

  def draft(conn, %{
        "title" => title,
        "content" => content,
        "drafterOpinion" => drafter_opinion,
        "approvalLines" => approval_lines
      }) do
    drafter_id = get_req_header(conn, "x-user-id") |> hd |> String.to_integer()

    {:ok, document} =
      Documents.draft_document(%{
        drafter_id: drafter_id,
        title: title,
        content: content,
        drafter_opinion: drafter_opinion,
        approval_lines: approval_lines
      })

    conn
    |> put_status(:created)
    |> show(%{"id" => document.id})
  end

  def approve(conn, %{"approve_type" => approve_type, "id" => document_id} = params) do
    approver_id = get_req_header(conn, "x-user-id") |> hd |> String.to_integer()
    opinion = Map.get(params, "opinion")

    with {:ok, _} <- _approve(approve_type, document_id, approver_id, opinion) do
      send_resp(conn, :ok, "success")
    end
  end

  defp _approve("confirm", document_id, approver_id, opinion) do
    Documents.confirm(document_id, approver_id, opinion)
  end

  defp _approve("reject", document_id, approver_id, opinion) do
    Documents.reject(document_id, approver_id, opinion)
  end

  defp _approve("pending", document_id, approver_id, _) do
    Documents.pending(document_id, approver_id)
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
