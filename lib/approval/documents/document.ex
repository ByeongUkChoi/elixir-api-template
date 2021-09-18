defmodule Approval.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :title, :string
    field :content, :string
    field :drafter_id, :integer
    field :drafter_opinion, :string
    field :status, :string
    has_many :approval_lines, Approval.Documents.ApprovalLine

    timestamps()
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:title, :content, :drafter_id, :drafter_opinion, :status])
    |> validate_required([:title, :content, :drafter_id, :drafter_opinion])
    |> cast_assoc(:approval_lines)
  end
end
