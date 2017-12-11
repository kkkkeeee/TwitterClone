defmodule App.APIPageView do
    use App.Web, :view
  
    def render("index.json", %{tweets: tweets, users: users}) do
      %{
        tweets: Enum.map(tweets, &tweets_json/1),
        users: Enum.map(users, &users_json/1)
      }
    end
  
    def tweets_json(tweet) do
      %{
        text: tweet.text,
        retweet_id: tweet.retweet_id,
        current_user_favorite_id: tweet.current_user_favorite_id,
        current_user_retweet_id: tweet.current_user_retweet_id,
      }
    end

    def users_json(user) do
        %{
            id: user.id,
            login: user.login,
            name: user.name,
            password: user.password,
            password_hash: user.password_hash
            
        }
    end
  end
  