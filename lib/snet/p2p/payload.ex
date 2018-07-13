defmodule SNet.P2P.Payload do

  alias SNet.P2P.Payload

  @ping "ping"

  @type t :: %Payload{
    type: String.t()
  }

  @derive [Poison.Encoder]
  defstruct [
    :type
  ]

  @spec ping() :: t
  def ping, do: %Payload{type: @ping}

  @spec encode!(t) :: String.t()
  def encode!(%Payload{} = payload), do: Poison.encode!(payload)

  @spec decode(String.t()) :: {:ok, t} | {:error, atom()}
  def decode(input) do
    case Poison.decode(input, as: %Payload{}) do
      {:ok, _} = result -> result
      {:error, {reason, _, _}} -> {:error, reason}
    end
  end
end
