defmodule SNet.P2P.CommandTest do
  use ExUnit.Case, async: true

  alias SNet.P2P.Payload
  alias SNet.P2P.Command

  defp call(%Payload{} = p) do
    p
      |> Payload.encode!
      |> Command.handle
  end

  describe "handle_ping_payload" do
    test "should return pong" do
      assert call(Payload.ping()) == {:ok, "pong"}
    end
  end
end
