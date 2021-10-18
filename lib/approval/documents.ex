defmodule Approval.Documents do
  @moduledoc """
  The Documents context.
  """

  alias Ecto.Multi

  alias Approval.Repo

  alias Approval.Documents.Document
  alias Approval.Documents.ApprovalLine

  def get_document_list(%{} = params) do
    Repo.paginate(Document, params)
  end

  def get_document_with_approval_lines(id) do
    Repo.get(Document, id)
    |> Repo.preload(:approval_lines)
  end

  @doc """
  문서를 기안한다.
  """
  def draft_document(attrs \\ %{}) do
    Document.insert_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  문서를 승인하다.
  """
  @spec confirm(integer(), integer(), String.t()) :: {:ok, %Document{}} | {:error, any}
  def confirm(document_id, approver_id, opinion) do
    Multi.new()
    |> Multi.run(:document, fn _, _ ->
      case get_document_with_approval_lines(document_id) do
        %Document{} = document -> {:ok, document}
        _ -> {:error, :not_found}
      end
    end)
    |> Multi.run(:approval_line, fn _, %{document: document} ->
      case get_approval_line(document, approver_id) do
        %ApprovalLine{} = approval_line -> {:ok, approval_line}
        _ -> {:error, "Not found approval line"}
      end
    end)
    |> Multi.run(:update, fn repo, %{approval_line: approval_line} ->
      ApprovalLine.approval_changeset(approval_line, %{
        approval_type: :CONFIRMED,
        opinion: opinion,
        acted_at: NaiveDateTime.local_now()
      })
      |> repo.update()

      {:ok, nil}
    end)
    |> Multi.run(:update_next_approval_line, fn repo,
                                                %{
                                                  document: document,
                                                  approval_line: approval_line
                                                } ->
      with next_approval_line <- get_next_approval_line(document, approval_line.sequence),
           true <- next_approval_line != nil do
        ApprovalLine.changeset(next_approval_line, %{received_at: NaiveDateTime.local_now()})
        |> repo.update()

        {:ok, nil}
      else
        _ ->
          Document.changeset(document, %{status: :CONFIRMED})
          |> repo.update()

          {:ok, nil}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{document: %Document{} = document}} -> {:ok, document}
      {:error, _, msg, _} -> {:error, msg}
    end
  end

  @doc """
  문서를 반려하다.
  기안자 의견 및 처리 시간 추가, 문서 상태 변경
  """
  @spec reject(integer(), integer(), String.t()) :: {:ok, %Document{}} | {:error, any}
  def reject(document_id, approver_id, opinion) do
    Multi.new()
    |> Multi.run(:document, fn _, _ ->
      case get_document_with_approval_lines(document_id) do
        %Document{} = document -> {:ok, document}
        _ -> {:error, "Not found document"}
      end
    end)
    |> Multi.run(:approval_line, fn _, %{document: document} ->
      case get_approval_line(document, approver_id) do
        %ApprovalLine{} = approval_line -> {:ok, approval_line}
        _ -> {:error, "Not found approval line"}
      end
    end)
    |> Multi.run(:update_approval_line, fn repo, %{approval_line: approval_line} ->
      ApprovalLine.approval_changeset(approval_line, %{
        approval_type: :REJECTED,
        opinion: opinion,
        acted_at: NaiveDateTime.local_now()
      })
      |> repo.update()
    end)
    |> Multi.run(:update_document, fn repo, %{document: document} ->
      Document.changeset(document, %{status: :REJECTED})
      |> repo.update()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{document: %Document{} = document}} -> {:ok, document}
      {:error, _, msg, _} -> {:error, msg}
    end
  end

  @doc """
  문서를 보류하다
  결재선 처리 시간 추가, 문서 상태 변경
  """
  @spec pending(integer(), integer()) :: {:ok, %Document{}} | {:error, any}
  def pending(document_id, approver_id) do
    Multi.new()
    |> Multi.run(:document, fn _, _ ->
      case get_document_with_approval_lines(document_id) do
        %Document{} = document -> {:ok, document}
        _ -> {:error, "Not found document"}
      end
    end)
    |> Multi.run(:approval_line, fn _, %{document: document} ->
      case get_approval_line(document, approver_id) do
        %ApprovalLine{} = approval_line -> {:ok, approval_line}
        _ -> {:error, "Not found approval line"}
      end
    end)
    |> Multi.run(:update_approval_line, fn repo, %{approval_line: approval_line} ->
      ApprovalLine.approval_changeset(approval_line, %{
        approval_type: :PENDING,
        opinion: nil,
        acted_at: nil
      })
      |> repo.update()
    end)
    |> Multi.run(:update_document, fn repo, %{document: document} ->
      Document.changeset(document, %{status: :PENDING})
      |> repo.update()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{document: %Document{} = document}} -> {:ok, document}
      {:error, _, msg, _} -> {:error, msg}
    end
  end

  # 문서의 결재자 번호로 현재 결재선 반환 (없으면 nil 반환)
  defp get_approval_line(%Document{} = document, approver_id) do
    document.approval_lines
    |> Enum.filter(fn approval_line ->
      approval_line.received_at != nil and
        (approval_line.acted_at == nil or approval_line.approval_type == PENDING)
    end)
    |> Enum.filter(fn approval_line -> approval_line.approver_id == approver_id end)
    |> List.first()
  end

  # 문서의 현재 결재선 번호로 다음 결재선을 반환하다. (다음 결재선이 없을 경우 nil 반환)
  defp get_next_approval_line(%Document{} = document, current_approval_line_sequence) do
    document.approval_lines
    |> Enum.find(fn approval_line ->
      approval_line.sequence == current_approval_line_sequence + 1
    end)
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

  ############## 기본 함수
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
