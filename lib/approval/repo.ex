defmodule Approval.Repo do
  use Ecto.Repo,
    otp_app: :approval,
    adapter: Ecto.Adapters.Postgres
end
