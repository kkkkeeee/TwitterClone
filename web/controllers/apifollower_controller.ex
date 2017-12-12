defmodule App.APIFollowerController do
    use App.Web, :controller
  
    alias App.Follower
    alias App.User

    def index(conn, %{"login"=> login, "password" => password, "follow_id" => follow_id} = params) do
        #user = conn.assigns[:user]
        loginconn = login(conn, params["login"], params["password"])
        current_user = loginconn.assigns[:current_user]
        {userid, _} = Integer.parse(params["follow_id"])
        follower = %Follower{user_id: userid, follower_id: current_user.id}
        case Repo.insert Follower.changeset(follower, %{}) do
          {:ok, _follower} ->
            #redirect conn, to: user_following_path(conn, :index, current_user.id)
            render loginconn, App.APIErrorView, "index.json", status: %{status: 30}
          {:error, _changeset} ->
            render loginconn, App.APIErrorView, "index.json", status: %{status: 31}
        end
    end

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
end
