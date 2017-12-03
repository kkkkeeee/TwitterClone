defmodule App.IntegrationTest do
  use App.IntegrationCase, async: true
  alias App.Repo
  alias App.User
  alias App.Retweet
  alias App.Tweet
  import App.Factory
  import App.Zipf

  setup do
    Ecto.Adapters.SQL.Sandbox.checkout(App.Repo)
    conn = build_conn()
    {:ok, conn: conn}
  end

  def send_tweets(login_conn, n) when n <= 1 do
    login_conn = login_conn |> follow_form(%{ tweet: %{
    text: "hello_#n"}}, %{identifier: "#send_tweets"})
  end

  def send_tweets(login_conn, n) do
    login_conn = login_conn |> follow_form(%{ tweet: %{
    text: "hello_#n"}}, %{identifier: "#send_tweets"})
    send_tweets(login_conn, n-1)
  end

  def follow_user(conn, n, follow_list, user_id) when n <= 1 do
    if Enum.at(follow_list, n-1) != nil do
      links = "/users/#{Enum.at(follow_list, n-1)}"
      conn = conn |> follow_link(links)
      conn = post(conn, user_follower_path(conn, :create, user_id))
      |> follow_redirect()
      |> follow_link( "Users" )
    else
      conn
    end
  end

  def follow_user(conn, n, follow_list, user_id) do
    links = "/users/#{Enum.at(follow_list, n-1)}"
    IO.puts links
    conn = conn |> follow_link(links)
    |> IO.inspect
    conn = post(conn, user_follower_path(conn, :create, user_id))
    |> follow_redirect()
    |> follow_link( "Users" )
    follow_user(conn, n-1, follow_list, user_id)
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

  test "test zipf", %{conn: conn} do
    zipf(10, 1.5) |> IO.inspect
  end

  @tag :wip
  test "Multiple users", %{conn: conn} do

    user_number = 400
    parent = self()
    distribution = zipf(user_number, 1.5)
    tweets_number = Enum.map(distribution, fn x -> round(x * user_number) end)
    users = Enum.map(1..user_number, fn x -> create(:user, no: x) end)
    Enum.map(users, fn x ->  Repo.insert! x end)
    all_users = Repo.all User |> order_by([u], [asc: u.id])
    min_id = Repo.aggregate(User, :min, :id)
    max_id = Repo.aggregate(User, :max, :id)
    user_ids = Enum.map(all_users, fn x -> x.id end)

    #simulate tweets and users
    pairs_user_tweets = List.zip([users,tweets_number])

    get_request = fn(pair) ->
      {current_user, number} = pair
      login_conn = Ecto.Adapters.SQL.Sandbox.allow(App.Repo, parent, self())
      get(conn, page_path(conn, :index) )
      #|> IO.inspect
      |> follow_link("Login")
      #|> IO.inspect
      |> follow_form(%{ login: %{
      login: current_user.login, password: current_user.password}}, %{identifier: "#login_new_user"})
      |> send_tweets(number)
    end

    async_get_request = fn(pair) ->
      caller = self()
      Ecto.Adapters.SQL.Sandbox.allow(App.Repo, parent, self())
      spawn(fn -> send(caller, {:result, get_request.(pair)})end)
    end

    get_result = fn ->
      receive do
        {:result, result} -> result
      end
    end

    conns = pairs_user_tweets |> Enum.map(&async_get_request.(&1)) |> Enum.map(fn(_) -> get_result.() end)

    query = Tweet |> order_by([t], [desc: t.id])
    tweets = Repo.all(query)
    min_tweet_id = Repo.aggregate(Tweet, :min, :id)

    users_conns = Enum.map(conns, fn x ->
    x |> follow_link( "Users")
    end)

    #simulate users and followers
    IO.inspect distribution

    follow_list_users = Enum.map(1..user_number, fn x -> Enum.map(x..x+round(Enum.at(distribution, x-1)*user_number), fn y -> Enum.at(user_ids, y) end) end)
    follow_list_numbers = Enum.map(1..user_number, fn x -> round(Enum.at(distribution, x-1) * user_number) + 1 end)

    #IO.inspect Enum.at(follow_list_numbers, x-1)

    Enum.map(1..user_number, fn x -> follow_user(Enum.at(users_conns, x-1),
                                                 Enum.at(follow_list_numbers, x-1),
                                                 Enum.at(follow_list_users, x-1),
                                                 Enum.at(user_ids, x-1))
    end)


    #tweets_conns = Enum.map(1..user_number, fn x ->
    #con = conns |> follow_link( "Tweets" )
    #post(con, tweet_retweet_path(con, :create, Enum.at(tweets, 0)))
    #|> follow_redirect()
    #end)

  end

end
