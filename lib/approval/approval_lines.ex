defmodule Approval.ApprovalLines do
  @moduledoc """
  The ApprovalLines context.
  """

  import Ecto.Query, warn: false
  alias Approval.Repo

  alias Approval.ApprovalLines.ApprovalLine

  @doc """
  Returns the list of approval_lines.

  ## Examples

      iex> list_approval_lines()
      [%ApprovalLine{}, ...]

  """
  def list_approval_lines do
    Repo.all(ApprovalLine)
  end

  @doc """
  Gets a single approval_line.

  Raises `Ecto.NoResultsError` if the Approval line does not exist.

  ## Examples

      iex> get_approval_line!(123)
      %ApprovalLine{}

      iex> get_approval_line!(456)
      ** (Ecto.NoResultsError)

  """
  def get_approval_line!(id), do: Repo.get!(ApprovalLine, id)

  @doc """
  Creates a approval_line.

  ## Examples

      iex> create_approval_line(%{field: value})
      {:ok, %ApprovalLine{}}

      iex> create_approval_line(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_approval_line(attrs \\ %{}) do
    %ApprovalLine{}
    |> ApprovalLine.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a approval_line.

  ## Examples

      iex> update_approval_line(approval_line, %{field: new_value})
      {:ok, %ApprovalLine{}}

      iex> update_approval_line(approval_line, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_approval_line(%ApprovalLine{} = approval_line, attrs) do
    approval_line
    |> ApprovalLine.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a approval_line.

  ## Examples

      iex> delete_approval_line(approval_line)
      {:ok, %ApprovalLine{}}

      iex> delete_approval_line(approval_line)
      {:error, %Ecto.Changeset{}}

  """
  def delete_approval_line(%ApprovalLine{} = approval_line) do
    Repo.delete(approval_line)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking approval_line changes.

  ## Examples

      iex> change_approval_line(approval_line)
      %Ecto.Changeset{data: %ApprovalLine{}}

  """
  def change_approval_line(%ApprovalLine{} = approval_line, attrs \\ %{}) do
    ApprovalLine.changeset(approval_line, attrs)
  end
end
