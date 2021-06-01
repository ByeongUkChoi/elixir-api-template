defmodule ApprovalWeb.DocumentController do
  use ApprovalWeb, :controller

  alias Approval.Documents
  alias Approval.Documents.Document

  alias Approval.ApprovalLines.ApprovalLine

  alias Approval.Repo
  alias Ecto.Multi

  action_fallback ApprovalWeb.FallbackController

  def index(conn, params) do
    {documents, pagination} = Document |> Repo.paginate(params)
    render(conn, "index.json", documents: documents, pagination: pagination)
  end

  def show(conn, %{"id" => id}) do
    document = Document |> Repo.get!(id) |> Repo.preload(:approval_lines)
    render(conn, "show.json", document: document)
  end

  def draft(conn, params) do
    {:ok, %{approval_lines_insert_all: _insert_all, document: document}} = Multi.new()
    |> Multi.insert(:document, %Document{
      title: params["title"],
      content: params["content"],
      drafter_id: get_req_header(conn, "x-user-id") |> hd |> String.to_integer(),
      drafter_opinion: params["opinion"],
    })
    |> Multi.merge(fn %{document: document} ->
      Multi.new()
      |> Multi.insert_all(:approval_lines_insert_all, ApprovalLine, Enum.map(params["approveLines"], fn(approve_line) ->
        %{
          document_id: document.id,
          sequence: approve_line["sequence"],
          approver_id: approve_line["approverId"],
          received_at: approve_line["sequence"] == 1 && document.inserted_at || nil
        }
      end))
    end)
    |> Repo.transaction()

    conn
    |> put_status(:created)
    |> show(%{"id" => document.id})
  end

  def approve(conn, %{"id" => id, "approve_type" => "confirm"}) do
    document = get_document_with_approval_lines(id)
    approver = get_approver(document, get_req_header(conn, "x-user-id") |> hd)
    # TODO: validate
    send_resp(conn, :ok, "confirm : #{document.id}, #{approver.id}")
  end

  def approve(conn, %{"id" => id, "approve_type" => "reject"}) do
    document = get_document_with_approval_lines(id)
    send_resp(conn, :ok, "reject : #{document.id}")
  end

  def approve(conn, %{"id" => id, "approve_type" => "pending"}) do
    document = get_document_with_approval_lines(id)
    send_resp(conn, :ok, "pending : #{document.id}")
  end

  defp get_document_with_approval_lines(id) do
    # TODO exception
    Document
    |> Repo.get!(id)
    |> Repo.preload(:approval_lines)
  end

  defp get_approver(%Document{} = document, approver_id) do
    # TODO: return ok:, error:
    document.approval_lines
    |> Enum.filter(fn approval_line -> approval_line.received_at != nil and approval_line.acted_at == nil end)
    |> Enum.filter(fn approval_line -> approval_line.approver_id == approver_id end)
    |> hd
  end

  ############
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
