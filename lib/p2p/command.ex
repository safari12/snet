defmodule SNet.P2P.Command do
  @moduledoc """
    TCP Server Commands
  """

  alias SNet.P2P.Payload

  @type return :: :ok | {:ok, String.t()} | {:error, atom()}

  @spec handle(String.t()) :: return
  def handle(data) do
    case Payload.decode(data) do
      {:ok, payload} -> handle_payload(payload)
      {:error, _reason} = err -> err
    end
  end

  @spec handle_payload(Payload.t()) :: return
  defp handle_payload(%Payload{type: "ping"}) do
    {:ok, "pong"}
  end

  defp handle_payload(_) do
    {:error, :unknown_type}
  end
end
