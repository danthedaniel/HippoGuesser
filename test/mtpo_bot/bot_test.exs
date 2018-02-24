defmodule MtpoBot.BotTest do
  use Mtpo.DataCase

  alias MtpoBot.Bot

  test "check_time returns nil on malformed input" do
    assert is_nil(Bot.check_time("foo"))
  end

  test "check_time expands input values without minutes" do
    assert Bot.check_time("40.99") == "0:40.99"
  end

  test "check_time passes through valid inputs" do
    assert Bot.check_time("0:40.99") == "0:40.99"
  end
end
