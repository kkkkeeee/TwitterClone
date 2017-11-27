defmodule MyApp.AboutIntegrationTest do
  use App.IntegrationCase, async: true

  setup do
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

  test "Create new user", %{conn: conn} do
    # get the root index page

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
    |> follow_form(%{ tweet: %{
    text: "hello"}}, %{identifier: "#send_tweets"})


    assert login_conn.status == 200

  end

end
