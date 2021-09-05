defmodule ApprovalWeb.DocumentController do
  use ApprovalWeb, :controller

  alias Approval.Documents
  alias Approval.Documents.Document

  alias Approval.Documents.ApprovalLine

  alias Approval.Repo
  alias Ecto.Multi

  action_fallback ApprovalWeb.FallbackController

  def index(conn, params) do
    {documents, pagination} = Documents.get_document_list(params)
    render(conn, "index.json", documents: documents, pagination: pagination)
  end

  def show(conn, %{"id" => id}) do
    document = Documents.get_document_with_approval_lines!(id)
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

  def approve(conn, params)  do
    document = Documents.get_document_with_approval_lines!(params["id"])
    approver_id = get_req_header(conn, "x-user-id") |> hd |> String.to_integer()
    approval_line = Documents.get_approval_line!(document, approver_id)
    case params["approve_type"] do
      "confirm" -> confirm(document, approval_line, params["opinion"])
      "reject" -> Documents.reject(document, approver_id, params["opinion"])
      "pending" -> pending(document, approval_line)
      _ -> :error
    end
    send_resp(conn, :ok, "success")
  end

  defp confirm(document, approval_line, opinion) do
    Repo.transaction(fn ->
      ApprovalLine.changeset(approval_line, %{opinion: opinion, acted_at: NaiveDateTime.local_now()})
      |> Repo.update!()

      with {:ok, next_approval_line} <- Documents.get_next_approval_line(document, approval_line.sequence) do
        ApprovalLine.changeset(next_approval_line, %{received_at: NaiveDateTime.local_now()})
        |> Repo.update!()
      end

      Document.changeset(document, %{status: CONFIRMED})
      |> Repo.update!()
    end)
    :ok
  end

  defp pending(document, approval_line) do
    Repo.transaction(fn ->
      ApprovalLine.changeset(approval_line, %{acted_at: NaiveDateTime.local_now()})
      |> Repo.update!()
      Document.changeset(document, %{status: PENDING})
      |> Repo.update!()
    end)
    :ok
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
