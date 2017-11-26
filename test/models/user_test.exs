defmodule App.UserTest do
  use App.ModelCase
  alias App.User
  alias App.Repo
  alias App.Tagging
  alias App.Favorite
  alias App.Retweet
  alias App.Tag
  alias App.Tweet

  import App.Factory
  import Ecto.Query

  @valid_attrs %{
    login: "joe",
    name: "Joe Smith",
    email: "joe@example.com",
    password: "password",
    password_confirmation: "password",
    password_hash: "$2b$12$HqVSS6vSstuedGr49dgnMe.OuC1xVTXBq7qWk2NavwUuzxRUALuAS",
    profile_picture: "default_profile.png"
  }
  @invalid_attrs %{}

  defp create_taggings(tweet) do
    tags = extract_tags(tweet.text)
    Enum.map(tags, fn(name) ->
      tag = create_or_get_tag(name)
      tagging_param = %{tag_id: tag.id, tweet_id: tweet.id}
      tagging_changeset = Tagging.changeset(%Tagging{}, tagging_param)
      Repo.insert! tagging_changeset
    end)
  end

  defp extract_tags(text) do
    Regex.scan(~r/\S*#(?<tag>:\[[^\]]|[a-zA-Z0-9]+)/, text, capture: :all_names) |> List.flatten
  end

  defp create_or_get_tag(name) do
    case Repo.one from t in Tag, where: ilike(t.name, ^name) do
      nil ->
        tag_param = %{name: name}
        tag_changeset = Tag.changeset(%Tag{}, tag_param)
        Repo.insert! tag_changeset
      tag ->
        tag
    end
  end

  defp delete_taggings(tweet) do
    Enum.map(tweet.taggings, fn(tagging) ->
      unless Repo.one(from t in Tagging, where: t.tag_id == ^tagging.tag.id) do
        Repo.delete! tagging.tag
      end
    end)
  end

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "create user" do
    user = Map.merge %User{}, @valid_attrs
    Repo.insert! user
    assert length(Repo.all(from u in User)) == 1
  end

  test "delete user" do
    user = Map.merge %User{}, @valid_attrs
    Repo.insert! user
    user = Repo.one! from u in User, where: u.login == ^user.login
    Repo.delete! user
    assert length(Repo.all(from u in User)) == 0
  end


  test "create multiple users" do
    users = Enum.map(1..1000, fn x -> create(:user, no: x) end)
    Enum.map(users, fn x ->  Repo.insert! x end)
    assert length(Repo.all(from u in User)) == 1000
  end

end
