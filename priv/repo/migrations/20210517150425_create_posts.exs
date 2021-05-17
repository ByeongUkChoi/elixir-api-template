defmodule Blog.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :content, :string
      add :authorId, :integer
      add :createdAt, :naive_datetime

      timestamps()
    end

  end
end
