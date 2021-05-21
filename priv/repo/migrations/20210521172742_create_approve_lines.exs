defmodule Approval.Repo.Migrations.CreateApproveLines do
  use Ecto.Migration

  def change do
    create table(:approve_lines) do
      add :sequence, :integer
      add :approver_id, :integer
      add :approve_type, :string
      add :opinion, :string
      add :received_at, :naive_datetime
      add :acted_at, :naive_datetime
      add :document_id, references(:documents, on_delete: :nothing)

      timestamps()
    end

    create index(:approve_lines, [:document_id])
  end
end
