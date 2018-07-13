defmodule SNet.P2P.PayloadTest do
  use ExUnit.Case, async: true

  alias SNet.P2P.Payload

  describe "ping" do
    test "should return type ping" do
      assert "ping" == Payload.ping().type
    end
  end
end
