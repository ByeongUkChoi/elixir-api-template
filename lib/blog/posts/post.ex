defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :authorId, :integer
    field :content, :string
    field :createdAt, :naive_datetime
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :authorId, :createdAt])
    |> validate_required([:title, :content, :authorId, :createdAt])
  end
end
