defmodule App.APISearchController do
    use App.Web, :controller
    alias App.Tweet
  
    def index(conn, %{"query" => query}) do
        tweets = (from t in Tweet, where: like(t.text, ^("%#{query}%")))
        |> Repo.all() |> Repo.preload(:user)
        render conn, "index.json", tweets: tweets
    end
  end