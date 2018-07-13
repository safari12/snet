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
end
