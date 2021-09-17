defmodule Approval.Repo do
  use Ecto.Repo,
    otp_app: :approval,
    adapter: Ecto.Adapters.MyXQL

  use Phoenix.Pagination, per_page: 10
end
