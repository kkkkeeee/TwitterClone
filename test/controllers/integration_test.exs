defmodule App.IntegrationTest do
  use App.IntegrationCase, async: true
  alias App.Repo
  alias App.User
  alias App.Retweet
  alias App.Tweet
  import App.Factory

  setup do
    #Ecto.Adapters.SQL.Sandbox.checkout(App.Repo)
    conn = build_conn()
    {:ok, conn: conn}
  end

  test "Basic page flow", %{conn: conn} do
    # get the root index page
    conn_user = get( conn, page_path(conn, :index) )
    # click/follow through the various about pages
    |> follow_link( "Users" )
    assert conn_user.status == 200

    conn_twitter = get( conn, page_path(conn, :index) )
    # click/follow through the various about pages
    |> follow_link( "Twitter" )
    assert conn_twitter.status == 200

    conn_twitter = get( conn, page_path(conn, :index) )
    # click/follow through the various about pages
    |> follow_link( "Signup" )
    assert conn_twitter.status == 200

    conn_tweets = get( conn, page_path(conn, :index) )
    # click/follow through the various about pages
    |> follow_link( "Tweets" )
    assert conn_tweets.status == 200

  end

  test "Signup new user", %{conn: conn} do
    # signup
    create_conn = get( conn, page_path(conn, :index) )
    |> follow_link( "Signup")
    |> follow_form(%{ user: %{
    login: "abc",
    password: "test.password",
    password_confirmation: "test.password",
    name: "xxx"}}, %{identifier: "#signup_new_user"})
    assert create_conn.status == 200
  end

  test "Login and Send tweet", %{conn: conn} do
    # get the root index page

    users = Enum.map(1..2, fn x -> create(:user, no: x) end)
    Enum.map(users, fn x ->  Repo.insert! x end)

    # signup
    create_conn = get( conn, page_path(conn, :index) )
    |> follow_link( "Signup")
    |> follow_form(%{ user: %{
    login: "abc",
    password: "test.password",
    password_confirmation: "test.password",
    name: "xxx"}}, %{identifier: "#signup_new_user"})
    assert create_conn.status == 200

    all_users = Repo.all User |> order_by([u], [asc: u.id])

    #loginin
    login_conn = get( conn, page_path(conn, :index) )
    |> follow_link("Login")
    |> follow_form(%{ login: %{
    login: "abc", password: "test.password"}}, %{identifier: "#login_new_user"})
    # simulate send a tweet
    |> follow_form(%{ tweet: %{
    text: "hello"}}, %{identifier: "#send_tweets"})

    assert login_conn.status == 200

  end

  test "Multiple users", %{conn: conn} do

    parent = self()
    users = Enum.map(1..4, fn x -> create(:user, no: x) end)
    Enum.map(users, fn x ->  Repo.insert! x end)
    all_users = Repo.all User |> order_by([u], [asc: u.id])
    min_id = Repo.aggregate(User, :min, :id)
    max_id = Repo.aggregate(User, :max, :id)
    user_ids = Enum.map(all_users, fn x -> x.id end)
    get_request = fn(x) ->
      get(conn, page_path(conn, :index) )
      |> follow_link("Login")
      |> follow_form(%{ login: %{
      login: x.login, password: x.password}}, %{identifier: "#login_new_user"})
      |> follow_form(%{ tweet: %{
      text: "hello"}}, %{identifier: "#send_tweets"})
    end

    all_tweets = Repo.all Tweet
    IO.inspect all_tweets
    
    conns = Enum.map(users, &get_request.(&1))

    users_conns = Enum.map(conns, fn x ->
    x |> follow_link( "Users" )
    end)

    #follow users
    Enum.map(users_conns, fn x ->
    x = x |> follow_link( "/users/#{min_id}")
    post(x, user_follower_path(x, :create, min_id))
    |> follow_redirect()
    end)

    tweets_conns = Enum.map(conns, fn x ->
    x |> follow_link( "Tweets" )
    post(x, tweet_favorite_path(x, :create, min_id))
    end)


  end

end
