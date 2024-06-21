defmodule LivePresenceWeb.Dashboard do
  alias LivePresenceWeb.Presence
  use LivePresenceWeb, :live_view

  @visitor_topic "visitor_topic"
  def mount(_params, %{"visitor" => visitor}, socket) do
    Presence.track(self(), @visitor_topic, socket.id, %{
      socket_id: socket.id,
      x: 24,
      y: 24,
      msg: "",
      name: visitor
    })

    LivePresenceWeb.Endpoint.subscribe(@visitor_topic)

    initial_visitors =
      Presence.list(@visitor_topic)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    IO.inspect("lenght of initial_visitors: #{length(initial_visitors)}")
    # dedupe the initial_visitors, only keeping one per socket_id
    fil_initial_visitors =
      Enum.uniq_by(initial_visitors, fn visitor -> visitor.socket_id end)

    updated =
      socket
      |> assign(:visitors, fil_initial_visitors)
      |> assign(:socket_id, socket.id)

    {:ok, updated}
  end

  # pattern match to handle the case where the visitor is not present
  def mount(_params, _session, socket) do
    {:ok, socket |> redirect(to: "/")}
  end

  def handle_event("mouse-move", %{"x" => x, "y" => y}, socket) do
    updatePresence(socket.id, %{x: x, y: y})
    {:noreply, socket}
  end

  def handle_event("send_message", %{"msg" => msg}, socket) do
    updatePresence(socket.id, %{msg: msg})
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

  def updatePresence(key, payload) do
    visitor_metas =
      Presence.get_by_key(@visitor_topic, key)[:metas]
      |> List.first()
      |> Map.merge(payload)

    Presence.update(self(), @visitor_topic, key, visitor_metas)
  end

  def render(assigns) do
    ~H"""
    <section class="flex flex-1 flex-col h-full justify-end items-center text-center">
      <form
        id="msgform"
        phx-submit="send_message"
        class="rounded-full w-full bg-gray-100 p-1.5 drop-shadow-lg flex mx-auto gap-2 border border-gray-300"
      >
        <input
          class="border w-full border-gray-200 py-2 px-4 bg-white text-gray-600 placeholder-gray-400 rounded-full text-sm focus:outline-none focus:ring-2 focus:ring-blue-300/50 focus:ring-offset-1 focus:ring-offset-blue-200/50  min-w-48"
          maxlength="45"
          aria-label="Your message"
          type="text"
          id="msg"
          name="msg"
          placeholder="Compose a message..."
        />
        <input
          id="submit-msg"
          type="submit"
          class="rounded-full bg-blue-600 text-white text-sm font-semibold py-1 px-4 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-300 focus:ring-offset-1 focus:ring-offset-blue-200/50"
          value="Send Message →"
        />
      </form>
    </section>
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
          class="shadow-md border shadow-neutral-100 ml-4 px-2 rounded-full text-[10px] font-medium"
        >
          <%= visitor.name %>
          <%= if visitor.msg != "" do %>
            -
          <% end %>
          <%!-- conditionall add a : when there is a msg, and render it in an 8px span --%>
          <%= if visitor.msg do %>
            <span class="text-[8px] font-normal"><%= visitor.msg %></span>
          <% end %>
        </span>
        <%!-- <span
          style={"background-color: #{colors[:bg]}; color: #{colors[:text]}; border-color: #{colors[:border]}"}
          class="mt-1 ml-4 rounded-lg p-1 text-[9px] text-left opacity-80 fit-content"
        >

        </span> --%>
      </aside>
    <% end %>
    """
  end
end
