defmodule LivePresenceWeb.PageController do
  use LivePresenceWeb, :controller

  def index(conn, _params) do
    session = conn |> get_session()

    case session do
      %{"visitor" => _visitor} ->
        conn
        |> redirect(to: "/dashboard")

      _ ->
        conn
        |> put_session(:visitor, LivePresenceWeb.Visitors.random_name())
        |> configure_session(renew: true)
        |> redirect(to: "/dashboard")
    end
  end
end
