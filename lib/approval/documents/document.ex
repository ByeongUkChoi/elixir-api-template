defmodule Approval.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :title, :string
    field :content, :string
    field :drafter_id, :integer
    field :drafter_opinion, :string
    field :status, Ecto.Enum, values: [:ON_PROGRESS, :PENDING, :CONFIRMED, :REJECTED]
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

  @doc false
  def insert_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:title, :content, :drafter_id, :drafter_opinion, :status])
    |> validate_required([:title, :content, :drafter_id, :drafter_opinion])
    |> cast_assoc(:approval_lines)
  end
end
