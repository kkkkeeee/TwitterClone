defmodule App.TwitterControllerTest do
  use App.ConnCase, async: true

  alias App.Repo
  alias App.Tagging
  alias App.Favorite
  alias App.Retweet
  alias App.Tag
  alias App.Tweet
  alias App.User

  import App.Factory

  test "can signup", %{conn: conn} do
    user = %{user: %{
      login: "login",
      name: "name",
      password: "password",
      password_confirmation: "password",
      email: "email"
    }}
    conn = post(conn, signup_path(conn, :create), user)
    assert conn.status == 302  # redirected to profile
    assert length(Repo.all from u in User, where: u.login == ^user.user.login) == 1
  end

  test "can login in", %{conn: conn} do
    conn = build_conn()
    users = Enum.map(1..2, fn x -> create(:user, no: x) end)
    Enum.map(users, fn x ->  Repo.insert! x end)
    Enum.map(users, fn x ->  login = %{login: %{login: x.login, password: x.password}}
                             assert post(conn, login_path(conn, :create), login).status == 302
                            end)
  end
  
end
