defmodule Mtpo.UsersTest do
  use Mtpo.DataCase

  alias Mtpo.Users

  describe "users" do
    # alias Mtpo.Users.User

    @valid_attrs %{name: "teaearlgraycold", perm_level: :user}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Users.create_user()

      user
    end

    test "can have permissions elevated" do
      user = user_fixture()
      {:ok, _} = Users.update_user(user, %{perm_level: :mod})
    end

    test "must have a name" do
      {:error, _} = Users.create_user(%{name: nil, perm_level: :user})
    end

    test "defaults to user perm_level" do
      {:ok, user} = Users.create_user(%{name: "teaearlgraycold"})
      assert user.perm_level == :user
    end

    test "have unique names" do
      {:ok, _} = Users.create_user(%{name: "teaearlgraycold", perm_level: :user})
      {:error, _} = Users.create_user(%{name: "teaearlgraycold", perm_level: :user})
    end

    test "normal users can not state change" do
      assert not Users.can_state_change(user_fixture())
    end

    test "whitelited mods can state change" do
      assert Users.can_state_change(user_fixture(%{perm_level: :mod, whitelisted: true}))
    end

    test "leaderboard is empty to start" do
        assert Users.leaderboard() == []
    end
  end
end
