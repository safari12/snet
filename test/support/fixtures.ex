defmodule SNet.Fixtures do
  alias SNet.P2P.Payload

  def open_connection do
    opts = [:binary, packet: 4, active: false]
    port = Application.fetch_env!(:snet, :port)
    :gen_tcp.connect('localhost', port, opts)
  end

  def open_connection_and_ping do
    {:ok, socket} = open_connection()

    ping = Payload.ping()
      |> Payload.encode!()

    "pong" = send_and_recv(socket, ping)
    {:ok, socket}
  end

  def send_and_recv(socket, payload) do
    :ok = :gen_tcp.send(socket, payload)
    recv(socket)
  end

  def recv(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end
