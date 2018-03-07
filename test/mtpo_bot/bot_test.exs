defmodule MtpoBot.BotTest do
  use Mtpo.DataCase

  alias MtpoBot.Bot

  test "check_time returns nil on malformed input" do
    :error = Bot.check_time("foo")
  end

  test "check_time expands input values without minutes" do
    {:ok, "0:40.99"} = Bot.check_time("40.99")
  end

  test "check_time passes through valid inputs" do
    {:ok, "0:40.99"} = Bot.check_time("0:40.99")
  end

  test "make_map can process an empty string" do
    assert Bot.make_map("", ",", "/") == %{}
  end

  test "make_map can process badges" do
    %{
      "subscriber" => "0",
      "moderator"  => "1"
    } = Bot.make_map("subscriber/0,moderator/1", ",", "/")
  end
end
