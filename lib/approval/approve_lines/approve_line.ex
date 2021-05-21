defmodule Approval.ApproveLines.ApproveLine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "approve_lines" do
    field :acted_at, :naive_datetime
    field :approve_type, :string
    field :approver_id, :integer
    field :opinion, :string
    field :received_at, :naive_datetime
    field :sequence, :integer
    field :document_id, :id

    timestamps()
  end

  @doc false
  def changeset(approve_line, attrs) do
    approve_line
    |> cast(attrs, [:sequence, :approver_id, :approve_type, :opinion, :received_at, :acted_at])
    |> validate_required([:sequence, :approver_id, :approve_type, :opinion, :received_at, :acted_at])
  end
end
