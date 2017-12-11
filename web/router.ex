defmodule App.Router do
  use App.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"] 
    plug :fetch_session
    plug :fetch_flash
  end

  scope "/", App do
    pipe_through :browser

    get "/", PageController, :index

    get  "/signup", SignupController, :index
    post "/signup", SignupController, :create

    get  "/login", LoginController, :index
    get  "/login/:login", LoginController, :show
    post "/login", LoginController, :create

    get "/logout", LogoutController, :index

    post "/search", SearchController, :index

    resources "/users", UserController, only: [:index, :show, :edit, :update] do
      resources "/tweets", TweetController, only: [:create]

      get "/followers", FollowerController, :index
      get "/following", FollowingController, :index
      get "/favorites", FavoriteController, :index

      post   "/follow", FollowerController, :create
      delete "/follow", FollowerController, :delete

    end

    resources "/tweets", TweetController, only: [:index, :show, :delete] do
      post   "/favorite", FavoriteController, :create
      delete "/favorite", FavoriteController, :delete

      post   "/retweet", RetweetController, :create
      delete "/retweet", RetweetController, :delete
    end

    get "/hashtag/:name", TagController, :show
  end

  scope "/api", App do
    pipe_through :api 
    #get "/", APIPageController, :index
    get  "/signup", APISignupController, :index
    #resources "/todos", TodoController, only: [:index]
    get  "/search", APISearchController, :index 

    get "/tweets", APITweetController, :index
  end
end


