defmodule App.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use App.ConnCase
      use PhoenixIntegration
    end
  end

end
