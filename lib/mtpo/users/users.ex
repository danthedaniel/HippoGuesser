defmodule Mtpo.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Mtpo.Repo
  alias Mtpo.Users
  alias Mtpo.Users.User
  alias Mtpo.Rounds
  alias Mtpo.Guesses.Guess

  @doc """
  A collection of the top `count` users who have won a round.
  """
  @spec leaderboard(number) :: [%{name: charlist, count: number}]
  def leaderboard(count \\ 20) do
    query = from g in Guess,
      join: r in assoc(g, :round),
      join: u in assoc(g, :user),
      select: %{name: u.name, count: count(g.user_id)},
      where: g.value == r.correct_value,
      group_by: u.name,
      order_by: [desc: :count],
      limit: ^count
    Repo.all query
  end

  @doc """
  All users that are whitelisted.
  """
  def whitelist do
    Repo.all from u in User, where: u.whitelisted == true
  end

  @doc """
  How many wins the user has.
  """
  def num_correct_guesses(%User{} = user) do
    query = from g in Guess,
      join: r in assoc(g, :round),
      select: count(r.id),
      where: g.user_id == ^user.id and g.value == r.correct_value
    Repo.one query
  end

  @doc """
  Whether the user has guessed in the current round.
  """
  def has_guessed(%User{} = user) do
    round = Rounds.current_round!
    case Repo.get_by(Guess, round_id: round.id, user_id: user.id) do
      nil -> false
      _ -> true
    end
  end

  @doc """
  If the user is privileged to change the state of a round.
  """
  def can_state_change(nil), do: false
  def can_state_change(%User{} = user) do
    user.whitelisted or user.perm_level == :admin
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    # TODO: What the fuck, why is this necessary?
    attrs = attrs
    |> Map.put_new(:perm_level, :user)
    |> Map.put_new(:whitelisted, false)

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  If a user is found, returns it. Else creates one.

  ## Examples

      iex> create_or_get(%{field: value})
      {:ok, %User{}}

      iex> create_or_get(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_or_get_user(attrs) do
    case Repo.get_by(User, attrs) do
      nil -> Users.create_user(attrs)
      result -> {:ok, result}
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
