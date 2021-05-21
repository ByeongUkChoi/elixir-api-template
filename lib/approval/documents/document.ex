defmodule Approval.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :content, :string
    field :drafter_id, :integer
    field :drafter_opinion, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:title, :content, :drafter_id, :drafter_opinion])
    |> validate_required([:title, :content, :drafter_id, :drafter_opinion])
  end
end
