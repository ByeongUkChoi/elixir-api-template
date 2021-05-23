defmodule ApprovalWeb.Router do
  use ApprovalWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApprovalWeb do
    pipe_through :api
    scope "/documents" do
      # get documments
      get "", DocumentController, :index
      get "/:id", DocumentController, :show

      # draft document
      post "", DocumentController, :draft

      # approve document
      put "/:id", DocumentController, :approve
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: ApprovalWeb.Telemetry
    end
  end
end
