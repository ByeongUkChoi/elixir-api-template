defmodule Approval.Repo do
  use Ecto.Repo,
    otp_app: :approval,
    adapter: Ecto.Adapters.Postgres
  use Phoenix.Pagination, per_page: 10
end
