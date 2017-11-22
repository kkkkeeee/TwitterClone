defmodule App.SearchController do
  use App.Web, :controller

  alias App.Tweet
  alias App.User

  def index(conn, %{"search" => %{"query" => query}}) do
      redirect conn, to: tweet_path(conn, :show, query)
  end
end
