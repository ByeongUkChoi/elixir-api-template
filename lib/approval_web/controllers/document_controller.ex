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

    # multi insert를 사용하지 않고 repo.insert 사용
    # {:ok, %{approval_lines_insert_all: _insert_all, document: document}} = Repo.insert(%Document{
    #   title: params["title"],
    #   content: params["content"],
    #   drafter_id: get_req_header(conn, "x-user-id") |> hd |> String.to_integer(),
    #   drafter_opinion: params["opinion"],
    #   approval_lines: Enum.map(params["approveLines"], fn(approve_line) ->
    #     %{
    #       sequence: approve_line["sequence"],
    #       approver_id: approve_line["approverId"],
    #       received_at: approve_line["sequence"] == 1 && NaiveDateTime.utc_now() || nil
    #     }
    #   end)
    # })

    # {:ok, %{approval_lines_insert_all: _insert_all, document: document}} = Multi.new()
    # |> Multi.insert(:document, %Document{
    #   title: params["title"],
    #   content: params["content"],
    #   drafter_id: get_req_header(conn, "x-user-id") |> hd |> String.to_integer(),
    #   drafter_opinion: params["opinion"],
    # })
    # |> Multi.merge(fn %{document: document} ->
    #   Multi.new()
    #   |> Multi.insert_all(:approval_lines_insert_all, ApprovalLine, Enum.map(params["approveLines"], fn(approve_line) ->
    #     %{
    #       document_id: document.id,
    #       sequence: approve_line["sequence"],
    #       approver_id: approve_line["approverId"],
    #       received_at: approve_line["sequence"] == 1 && document.inserted_at || nil
    #     }
    #   end))
    # end)
    # |> Repo.transaction()

    conn
    |> put_status(:created)
    |> show(%{"id" => document.id})
  end

  def approve(conn, params) do
    document = Documents.get_document_with_approval_lines(params["id"])
    approver_id = get_req_header(conn, "x-user-id") |> hd |> String.to_integer()

    case params["approve_type"] do
      "confirm" -> Documents.confirm(document, approver_id, params["opinion"])
      "reject" -> Documents.reject(document, approver_id, params["opinion"])
      "pending" -> Documents.pending(document, approver_id)
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
