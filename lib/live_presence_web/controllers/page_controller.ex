defmodule LivePresenceWeb.PageController do
  use LivePresenceWeb, :controller

  def index(conn, _params) do
    session = conn |> get_session()

    case session do
      %{"visitor" => _visitor} ->
        conn
        |> redirect(to: "/home")

      _ ->
        conn
        |> put_session(:visitor, LivePresenceWeb.Name.random_name())
        |> configure_session(renew: true)
        |> redirect(to: "/home")
    end
  end
end
