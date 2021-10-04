defmodule Approval.Documents.ApprovalLine do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Enum
  alias Approval.Documents.Document

  schema "approval_lines" do
    # field :document_id, :id
    field :sequence, :integer
    field :approver_id, :integer
    field :approval_type, Enum, values: [:PENDING, :CONFIRMED, :REJECTED]
    field :opinion, :string
    field :received_at, :naive_datetime
    field :acted_at, :naive_datetime
    belongs_to :document, Document
  end

  @doc false
  def changeset(approval_line, attrs) do
    approval_line
    |> cast(attrs, [
      :sequence,
      :approver_id,
      :approval_type,
      :opinion,
      :received_at,
      :acted_at,
      :document_id
    ])
    |> validate_required([:sequence, :approver_id])
  end

  def approval_changeset(approval_line, %{
        approval_type: approval_type,
        opinion: opinion,
        acted_at: acted_at
      }) do
    change(approval_line, %{approval_type: approval_type, acted_at: acted_at})
    |> cast(%{opinion: opinion}, [:opinion])
  end
end
