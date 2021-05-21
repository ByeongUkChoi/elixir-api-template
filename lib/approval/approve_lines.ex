defmodule Approval.ApproveLines do
  @moduledoc """
  The ApproveLines context.
  """

  import Ecto.Query, warn: false
  alias Approval.Repo

  alias Approval.ApproveLines.ApproveLine

  @doc """
  Returns the list of approve_lines.

  ## Examples

      iex> list_approve_lines()
      [%ApproveLine{}, ...]

  """
  def list_approve_lines do
    Repo.all(ApproveLine)
  end

  @doc """
  Gets a single approve_line.

  Raises `Ecto.NoResultsError` if the Approve line does not exist.

  ## Examples

      iex> get_approve_line!(123)
      %ApproveLine{}

      iex> get_approve_line!(456)
      ** (Ecto.NoResultsError)

  """
  def get_approve_line!(id), do: Repo.get!(ApproveLine, id)

  @doc """
  Creates a approve_line.

  ## Examples

      iex> create_approve_line(%{field: value})
      {:ok, %ApproveLine{}}

      iex> create_approve_line(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_approve_line(attrs \\ %{}) do
    %ApproveLine{}
    |> ApproveLine.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a approve_line.

  ## Examples

      iex> update_approve_line(approve_line, %{field: new_value})
      {:ok, %ApproveLine{}}

      iex> update_approve_line(approve_line, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_approve_line(%ApproveLine{} = approve_line, attrs) do
    approve_line
    |> ApproveLine.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a approve_line.

  ## Examples

      iex> delete_approve_line(approve_line)
      {:ok, %ApproveLine{}}

      iex> delete_approve_line(approve_line)
      {:error, %Ecto.Changeset{}}

  """
  def delete_approve_line(%ApproveLine{} = approve_line) do
    Repo.delete(approve_line)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking approve_line changes.

  ## Examples

      iex> change_approve_line(approve_line)
      %Ecto.Changeset{data: %ApproveLine{}}

  """
  def change_approve_line(%ApproveLine{} = approve_line, attrs \\ %{}) do
    ApproveLine.changeset(approve_line, attrs)
  end
end
