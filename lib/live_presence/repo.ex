defmodule LivePresence.Repo do
  use Ecto.Repo,
    otp_app: :live_presence,
    adapter: Ecto.Adapters.Postgres
end
