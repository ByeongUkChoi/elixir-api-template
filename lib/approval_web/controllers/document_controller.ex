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
    send_resp(conn, :ok, "confirm : #{id}")
  end

  def approve(conn, %{"id" => id, "approve_type" => "reject"}) do
    send_resp(conn, :ok, "reject : #{id}")
  end

  def approve(conn, %{"id" => id, "approve_type" => "pending"}) do
    send_resp(conn, :ok, "pending : #{id}")
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
