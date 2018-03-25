defmodule MtpoBot.BotTest do
  use Mtpo.DataCase

  alias MtpoBot.Bot

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
