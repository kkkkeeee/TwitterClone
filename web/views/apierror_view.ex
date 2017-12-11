defmodule App.APIErrorView do
    use App.Web, :view

    def render("index.json", %{status: status}) do
        %{
          status: status.status
        }
    end

    def render("notlogin.json", %{status: status}) do
        %{
          status: status.status
        }
    end
end