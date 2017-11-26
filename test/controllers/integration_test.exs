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
    create_conn = get( conn, page_path(conn, :index) )
    |> follow_link( "Signup" )
    |> follow_form(%{ user: %{
    login: "user@example.com",
    password: "test.password",
    password_confirmation: "test.password",
    name: "New User"}}, %{identifier: "#signup_new_user"})
    assert create_conn.status == 200
  end

end
