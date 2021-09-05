defmodule Approval.Documents do
  @moduledoc """
  The Documents context.
  """

  alias Approval.Repo

  alias Approval.Documents.Document
  alias Approval.Documents.ApprovalLine

  @spec get_document_list(map) ::
          {any,
           %Phoenix.Pagination{
             items: [],
             max_page: any,
             page: any,
             params: any,
             per_page: integer,
             total_count: any,
             total_pages: integer
           }}
  def get_document_list(params) do
    Repo.paginate(Document, params)
  end

  def get_document_with_approval_lines!(id) do
    Repo.get!(Document, id)
    |> Repo.preload(:approval_lines)
  end

  @doc """
  문서의 결재자 번호로 현재 결재선 반환
  """
  def get_approval_line!(%Document{} = document, approver_id) do
    document.approval_lines
    |> Enum.filter(fn approval_line -> approval_line.received_at != nil and ( approval_line.acted_at == nil or approval_line.approval_type == PENDING) end)
    |> Enum.filter(fn approval_line -> approval_line.approver_id == approver_id end)
    |> List.first()
  end

  @doc """
  TODO: 반환을 튜플이 아닌 결재선 or nil 로 할지..

  문서의 현재 결재선 번호로 다음 결재선을 반환하다.

  다음 결재선이 있을 경우
  {:ok, 다음 결재선}
  다음 결재선이 없을 경우
  {:error, nil}
  """
  def get_next_approval_line(%Document{} = document, current_approval_line_sequence) do
    approval_line = document.approval_lines
    |> Enum.filter(fn approval_line -> approval_line.sequence == current_approval_line_sequence + 1 end)
    |> hd

    case approval_line do
      nil -> {:error, nil}
      _ -> {:ok, approval_line}
    end
  end

  @doc """
  문서를 승인하다.
  """
  def confirm(document, approver_id, opinion) do
    approval_line = get_approval_line!(document, approver_id)

    Repo.transaction(fn ->
      ApprovalLine.changeset(approval_line, %{opinion: opinion, acted_at: NaiveDateTime.local_now()})
      |> Repo.update!()

      with {:ok, next_approval_line} <- get_next_approval_line(document, approval_line.sequence) do
        ApprovalLine.changeset(next_approval_line, %{received_at: NaiveDateTime.local_now()})
        |> Repo.update!()
      end

      Document.changeset(document, %{status: CONFIRMED})
      |> Repo.update!()
    end)
    :ok
  end

  @doc """
  문서를 반려하다.
  기안자 의견 및 처리 시간 추가, 문서 상태 변경
  """
  def reject(%Document{} = document, approver_id, opinion) do
    approval_line = get_approval_line!(document, approver_id)

    Repo.transaction(fn ->
      ApprovalLine.changeset(approval_line, %{opinion: opinion, acted_at: NaiveDateTime.local_now()})
      |> Repo.update!()

      Document.changeset(document, %{status: REJECTED})
      |> Repo.update!()
    end)
    :ok
  end

  @doc """
  문서를 보류하다
  결재선 처리 시간 추가, 문서 상태 변경
  """
  def pending(document, approver_id) do
    approval_line = get_approval_line!(document, approver_id)

    Repo.transaction(fn ->
      ApprovalLine.changeset(approval_line, %{acted_at: NaiveDateTime.local_now()})
      |> Repo.update!()
      Document.changeset(document, %{status: PENDING})
      |> Repo.update!()
    end)
    :ok
  end

  ######

  @doc """
  Returns the list of documents.

  ## Examples

      iex> list_documents()
      [%Document{}, ...]

  """
  def list_documents do
    Repo.all(Document)
  end

  @doc """
  Gets a single document.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(123)
      %Document{}

      iex> get_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document!(id), do: Repo.get!(Document, id)

  @spec create_document(
          :invalid
          | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: any
  @doc """
  Creates a document.

  ## Examples

      iex> create_document(%{field: value})
      {:ok, %Document{}}

      iex> create_document(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a document.

  ## Examples

      iex> update_document(document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a document.

  ## Examples

      iex> delete_document(document)
      {:ok, %Document{}}

      iex> delete_document(document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.

  ## Examples

      iex> change_document(document)
      %Ecto.Changeset{data: %Document{}}

  """
  def change_document(%Document{} = document, attrs \\ %{}) do
    Document.changeset(document, attrs)
  end
end
