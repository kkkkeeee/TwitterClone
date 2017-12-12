defmodule App.APITweetController do
    use App.Web, :controller
    alias App.Favorite
    alias App.Retweet
    alias App.Tag
    alias App.Tagging
    alias App.Tweet
    alias App.User
    #import App.SetUser
    #plug App.LoginRequired when action in [:index, :delete]
    #plug App.SetUser when action in [:index]
    defp login(conn, login, password) do
        case authenticate login, password do
            {:ok, user} ->
              conn
              |> User.put_current_user(user)

            :error ->
              conn
              |> render(App.APIErrorView, "index.json", status: %{status: 11})
        end
    end

    defp authenticate(login, password) do
        case Repo.get_by User, login: login do
          nil  ->
            :error
          user ->
            if User.validate_password password, user.password_hash do
              {:ok, user}
            else
              :error
            end
        end
    end

    def index(conn, %{"login"=> login, "password" => password, "tweet" => tweet} = params) do
        loginconn = login(conn, params["login"], params["password"])
        current_user = loginconn.assigns[:current_user]
          {state, _} = Repo.transaction fn ->
            tweet_changeset = Tweet.changeset %Tweet{user_id: current_user.id}, %{"text" => params["tweet"]}
            case Repo.insert tweet_changeset do
              {:ok, tweet} ->
                create_taggings(tweet)
              {:error, tweet_changeset} ->
                render loginconn, App.APIErrorView, "index.json", status: %{status: 11}
            end
          end
          if state == :ok do
            render(loginconn, "index.json", status: %{status: 10})
          end     
    end

    defp create_taggings(tweet) do
        tags = extract_tags(tweet.text)
        Enum.map(tags, fn(name) ->
          tag = create_or_get_tag(name)
          tagging_param = %{tag_id: tag.id, tweet_id: tweet.id}
          tagging_changeset = Tagging.changeset(%Tagging{}, tagging_param)
          Repo.insert! tagging_changeset
        end)
      end
    
      defp extract_tags(text) do
        Regex.scan(~r/\S*#(?<tag>:\[[^\]]|[a-zA-Z0-9]+)/, text, capture: :all_names) |> List.flatten
      end
    
      defp create_or_get_tag(name) do
        case Repo.one from t in Tag, where: ilike(t.name, ^name) do
          nil ->
            tag_param = %{name: name}
            tag_changeset = Tag.changeset(%Tag{}, tag_param)
            Repo.insert! tag_changeset
          tag ->
            tag
        end
    end
end