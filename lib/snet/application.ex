defmodule SNet.Application do
  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:snet, :port)

    children = [
      # P2P Processes
      {SNet.P2P.Peers, []},
      {Task.Supervisor, name: SNet.P2P.Server.TasksSupervisor},
      {Task, fn -> SNet.P2P.Server.accept(port) end}
    ]

    opts = [strategy: :one_for_one, name: SNet.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
