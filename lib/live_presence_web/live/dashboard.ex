defmodule LivePresenceWeb.Dashboard do
  alias LivePresenceWeb.Presence
  use LivePresenceWeb, :live_view

  @visitor_topic "visitor_topic"
  def mount(_params, %{"visitor" => visitor}, socket) do
    Presence.track(self(), @visitor_topic, socket.id, %{
      socket_id: socket.id,
      x: 24,
      y: 24,
      name: visitor
    })

    LivePresenceWeb.Endpoint.subscribe(@visitor_topic)

    initial_visitors =
      Presence.list(@visitor_topic)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    updated =
      socket
      |> assign(:visitors, initial_visitors)
      |> assign(:socket_id, socket.id)

    {:ok, updated}
  end

  # pattern match to handle the case where the visitor is not present
  def mount(_params, _session, socket) do
    {:ok, socket |> redirect(to: "/")}
  end

  def handle_event("mouse-move", %{"x" => x, "y" => y}, socket) do
    key = socket.id
    payload = %{x: x, y: y}

    visitor_metas =
      Presence.get_by_key(@visitor_topic, key)[:metas]
      |> List.first()
      |> Map.merge(payload)

    Presence.update(self(), @visitor_topic, key, visitor_metas)

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    visitors =
      Presence.list(@visitor_topic)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    updated =
      socket
      |> assign(visitors: visitors)
      |> assign(socket_id: socket.id)

    {:noreply, updated}
  end

  def render(assigns) do
    ~H"""
    <%= for visitor <- @visitors do %>
      <% colors = LivePresenceWeb.Visitors.random_color(visitor.name) %>
      <aside
        style={"left: #{visitor.x}%; top: #{visitor.y}%"}
        id="mouse-tracker"
        phx-hook="MouseTracker"
        class="text-emerald-500 pb-6 flex flex-col absolute pointer-events-none whitespace-nowrap overflow-hidden"
      >
        <svg
          class="size-4"
          xmlns="http://www.w3.org/2000/svg"
          width="20"
          height="20"
          fill="none"
          viewBox="0 0 20 20"
        >
          <path
            fill="currentColor"
            style={"fill: #{colors[:cursor]}"}
            d="M19.438 6.716 1.115.05A.832.832 0 0 0 .05 1.116L6.712 19.45a.834.834 0 0 0 1.557.025l3.198-8 7.995-3.2a.833.833 0 0 0 0-1.559h-.024Z"
          >
          </path>
        </svg>
        <span
          style={"background: #{colors[:bg]}; color: #{colors[:text]}; border-color: #{colors[:border]}"}
          class="shadow-md border shadow-neutral-100 ml-4 px-2 rounded-full text-[10px]  font-medium"
        >
          <%= visitor.name %>
        </span>
      </aside>
    <% end %>
    """
  end
end
