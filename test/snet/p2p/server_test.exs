defmodule SNet.P2P.ServerTest do
  use ExUnit.Case, async: false

  import SNet.Fixtures

  alias SNet.P2P.{Payload, Server, Peers}

  setup do
    :ok = Peers.remove_all()
    {:ok, socket} = open_connection_and_ping()
    {:ok, socket: socket}
  end

  describe "ping command" do
    test "should return pong response", %{socket: socket} do
      payload = Payload.ping
        |> Payload.encode!

      assert send_and_recv(socket, payload) == "pong"
    end
  end

  describe "peers" do
    test "should return 3 peers when 2 are connected", %{socket: _socket} do
      {:ok, _socket1} = open_connection_and_ping()
      {:ok, _socket2} = open_connection_and_ping()
      n = length(Peers.get_all)
      assert n == 3
    end
  end

  describe "broadcast" do
    test "should return test payload", %{socket: socket} do
      {:ok, socket1} = open_connection_and_ping()
      n = length(Peers.get_all)
      assert n == 2
      payload = "test"
      assert :ok = Server.broadcast(payload)
      for s <- [socket, socket1], do: assert(recv(s) == payload)
    end
  end
end
