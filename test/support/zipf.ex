defmodule App.Zipf do
  @moduledoc """
  Documentation for Zipf distribution
  zipf = f(x) = c/x^s  where x=1,..,n
  c = (sum_i^n (1/i)^s)^{-1}
  """

  def zipf(numUser, skew \\ 1.5) do # input: number of users, and a constant skew>0
    bottom = getBottom(numUser, 0.0, skew)
    IO.puts ("bottom #{bottom}")
    Enum.map(1..numUser, fn x -> output(x, bottom, skew) end)
  end

  def getBottom(i, bottom, skew) when i <= 1 do
    bottom = bottom + 1.0/i #(:math.pow(i, skew))
    bottom
  end

  def getBottom(i, bottom, skew) do
    newBottom = bottom + 1.0/ (:math.pow(i, skew))
    getBottom(i-1, newBottom, skew)
  end

  def getProbability(rank, bottom, skew) do
    1.0 / (:math.pow(rank, skew)*bottom)
  end

  def output(i, bottom, skew) do
    prob = getProbability(i, bottom, skew)
  end

end
