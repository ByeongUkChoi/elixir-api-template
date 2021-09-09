defmodule Approval.Documents.ApprovalLine do
  use Ecto.Schema
  import Ecto.Changeset

  alias Approval.Documents.Document

  schema "approval_lines" do
    # field :document_id, :id
    field :sequence, :integer
    field :approver_id, :integer
    field :approval_type, :string
    field :opinion, :string
    field :received_at, :naive_datetime
    field :acted_at, :naive_datetime
    belongs_to :document, Document
  end

  @doc false
  def changeset(approval_line, attrs) do
    approval_line
    |> cast(attrs, [:sequence, :approver_id, :approval_type, :opinion, :received_at, :acted_at])
    |> validate_required([:approver_id, :approval_type])
    # |> validate_required([:sequence, :approver_id, :approval_type, :opinion, :received_at, :acted_at])
  end
end
