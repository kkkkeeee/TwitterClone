defmodule App.UserController do
  use App.Web, :controller

  alias App.Tweet
  alias App.Retweet
  alias App.User
  alias App.Follower

  import Ecto.Changeset
  @num_tweets 5

  plug App.LoginRequired when action in [:edit, :update]
  plug App.SetUser when action in [:show]

  def index(conn, _params) do
    users = Repo.all User |> order_by([u], [asc: u.name])
    render conn, "index.html", users: users
  end

  def show(conn, _params) do
    user = conn.assigns[:user]
    changeset = Tweet.changeset %Tweet{}
    #added by keke to show the tweet posted by the user this current user is following
    #tweets = 
    #       Tweet |> join(:inner, [t], f in Follower, f.follower_id == ^user.id and t.user_id == f.user_id)             
    #tweets = Repo.all(tweets) |> Repo.preload(:user)
    #select * from(
    #  select * from tweets t where t.user_id = $1
    #  union
    query = """ 
          select * from
          (select t.* from tweets t, followers f
          where f.follower_id = $1 and t.user_id = f.user_id 
          and t.inserted_at > (select max(t2.inserted_at) 
                               from tweets t2
                               where t2.user_id = $1)
          order by t.inserted_at desc) s
          limit $2
    """
    res = Ecto.Adapters.SQL.query!(App.Repo, query, [user.id, @num_tweets])
    cols = Enum.map res.columns, &(String.to_atom(&1)) # b
    
    tweets = Enum.map res.rows, fn(row) ->
      struct(App.Tweet, Enum.zip(cols, row)) # c
    end
    tweets = tweets |> Repo.preload(:user)
    #tweets = Tweet.changeset(%Tweet{}, tweets)
    #IO.puts(", tweets: #{inspect tweets}")
    #query = Tweet|> join(:inner, [t], u in User, (u.id == ^user.id or u.id == (from f in Follower, where f.follower_id == ^user.id, select f.user_id)) 
    #          and t.user_id == u.id) 
    #tweets = Repo.all(query)
    #end added by keke

    render conn, "show.html", user: user, changeset: changeset, tweets: tweets #added by keke
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get! User, id
    changeset = User.changeset user
    render conn, "edit.html", user: user, changeset: changeset
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get! User, id
    changeset = User.changeset user, user_params

    # authorize user update
    password = get_change(changeset, :password)
    unless User.validate_password password, user.password_hash do
      new_changeset = %{changeset | action: :update } |> add_error(:password, gettext "wrong password")
      render conn, "edit.html", user: user, changeset: new_changeset
    end

    # set new password? (optional)
    new_password = get_change changeset, :new_password
    changeset = if String.length(new_password) > 0 do
      put_change(changeset, :password, new_password) |> User.with_password_hash
    else
      changeset
    end

    photo = user_params["photo"]
    changeset = if photo do
      name = "profile_picture_" <> id
      dst = Path.join([:code.priv_dir(:app), "static", "images", name])
      File.cp! photo.path, dst
      put_change changeset, :profile_picture, name
    else
      changeset
    end

    case Repo.update changeset do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext "Settings updated successfully")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render conn, "edit.html", user: user, changeset: changeset
    end
  end
end
