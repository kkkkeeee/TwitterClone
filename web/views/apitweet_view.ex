defmodule App.APITweetView do
    use App.Web, :view

    def render("index.json", %{status: status}) do
        %{
          status: status.status
        }
    end
end