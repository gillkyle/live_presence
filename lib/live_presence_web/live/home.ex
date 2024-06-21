defmodule LivePresenceWeb.Home do
  use LivePresenceWeb, :live_view

  def mount(_params, %{"visitor" => visitor}, socket) do
    updated =
      socket
      |> assign(:x, 24)
      |> assign(:y, 24)
      |> assign(:visitor, visitor)

    {:ok, updated}
  end

  # pattern match to handle the case where the visitor is not present
  def mount(_params, _session, socket) do
    {:ok, socket |> redirect(to: "/")}
  end

  def handle_event("mouse-move", %{"x" => x, "y" => y}, socket) do
    updated =
      socket
      |> assign(:x, x)
      |> assign(:y, y)

    {:noreply, updated}
  end

  def render(assigns) do
    ~H"""
    <aside
      style={"left: #{@x}%; top: #{@y}%"}
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
          class="text-emerald-500"
          d="M19.438 6.716 1.115.05A.832.832 0 0 0 .05 1.116L6.712 19.45a.834.834 0 0 0 1.557.025l3.198-8 7.995-3.2a.833.833 0 0 0 0-1.559h-.024Z"
        >
        </path>
      </svg>
      <span class="bg-emerald-100/50 border border-emerald-100 shadow-md shadow-neutral-100 ml-4 px-2 rounded-full text-[10px] text-emerald-600 font-medium">
        <%= @visitor %>
      </span>
    </aside>
    """
  end
end
