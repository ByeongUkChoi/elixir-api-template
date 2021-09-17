defmodule Approval.Repo.Migrations.CreateApprovalLines do
  use Ecto.Migration

  def change do
    create table(:approval_lines) do
      add :sequence, :integer
      add :approver_id, :integer
      add :approval_type, :string
      add :opinion, :string
      add :received_at, :naive_datetime
      add :acted_at, :naive_datetime
      add :document_id, references(:documents, on_delete: :nothing)
    end

    create index(:approval_lines, [:document_id])
  end
end
