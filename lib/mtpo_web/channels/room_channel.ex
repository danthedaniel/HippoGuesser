defmodule MtpoWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, %{state: "closed"}, socket}
  end

  def handle_in("start", _params, socket) do
    broadcast! socket, "start", %{body: ""}
    {:reply, :ok, socket}
  end
  def handle_in("stop", _params, socket) do
    broadcast! socket, "stop", %{body: ""}
    {:reply, :ok, socket}
  end
  def handle_in("winner", %{body: winning_time}, socket) do
    broadcast! socket, "winner", %{body: winning_time}
    {:reply, :ok, socket}
  end
end
