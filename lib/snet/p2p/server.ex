require Logger

defmodule SNet.P2P.Server do
  @moduledoc """
    TCP Server to handle communications between peers
  """

  alias SNet.P2P.{Peers, Command}

  @spec accept(integer) :: no_return()
  def accept(port) do
    opts = [
      :binary,
      packet: 4,
      active: false,
      reuseaddr: true
    ]
    {:ok, listen_socket} = :gen_tcp.listen(port, opts)

    Logger.info('accepting connections on port #{port}')
    loop_acceptor(listen_socket)
  end

  @spec loop_acceptor(port()) :: no_return()
  defp loop_acceptor(listen_socket) do
    {:ok, socket} = :gen_tcp.accept(listen_socket)

    case handle_socket(socket) do
      :ok -> loop_acceptor(listen_socket)
      {:error, reason} -> Logger.info('unable to accept connection: #{reason}')
    end
  end

  @spec handle_socket(port()) :: :ok | {:error, atom()}
  def handle_socket(socket) do
    Peers.add(socket)

    {:ok, pid} = Task.Supervisor.start_child(
      SNet.P2P.Server.TasksSupervisor,
      fn -> serve(socket) end)

    :gen_tcp.controlling_process(socket, pid)
  end

  @spec serve(port()) :: no_return()
  defp serve(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        handle_incoming_data(socket, data)
        serve(socket)
      {:error, _} ->
        Logger.info('socket died')
        Peers.remove(socket)
        exit(:shutdown)
    end
  end

  @spec broadcast(String.t(), [port()]) :: :ok
  def broadcast(_data, peers \\ Peers.get_all())
  def broadcast(_data, []), do: :ok

  def broadcast(data, [p | peers]) do
    case send_data(data, p) do
      {:error, _} ->
        Logger.info('socket not reachable, forget it')
        Peers.remove(p)
      _ -> broadcast(data, peers)
    end
  end

  @spec handle_incoming_data(port(), String.t()) :: :ok | {:error, atom()} | no_return()
  defp handle_incoming_data(socket, data) do
    case Command.handle(data) do
      {:ok, response} ->
        send_data(response, socket)
      :ok ->
        :ok
      {:error, :unknown_type} ->
        send_data('unknown type', socket)
      {:error, :invalid} ->
        send_data('invalid json', socket)
      {:error, reason} ->
        Logger.info(reason)
    end
  end

  @spec send_data(iodata(), port()) :: :ok | {:error, atom()}
  def send_data(data, socket) do
    :gen_tcp.send(socket, data)
  end
end
