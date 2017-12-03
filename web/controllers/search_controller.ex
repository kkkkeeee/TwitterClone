defmodule App.SearchController do
  use App.Web, :controller

  def index(conn, %{"search" => %{"query" => query}}) do
      redirect conn, to: tweet_path(conn, :show, query)
  end
end
