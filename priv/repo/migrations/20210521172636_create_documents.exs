defmodule Approval.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :title, :string
      add :content, :string
      add :drafter_id, :integer
      add :drafter_opinion, :string
      add :status, :string

      timestamps()
    end

  end
end
