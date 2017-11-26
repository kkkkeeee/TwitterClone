defmodule App.Factory do
  alias App.Tweet
  alias App.User
  alias App.Repo

  def create(:user, no: no), do: create_user(no)

  def create_user(no) do
    %App.User{
      login: "joe#{no}",
      name: "Joe Smith#{no}",
      email: "email-#{no}@example.com",
      password: "password",
      password_confirmation: "password",
      password_hash: "$2b$12$HqVSS6vSstuedGr49dgnMe.OuC1xVTXBq7qWk2NavwUuzxRUALuAS",
      profile_picture: "default_profile.png"
    }
  end

end
