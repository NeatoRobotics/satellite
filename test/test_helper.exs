ExUnit.start()

defmodule Double do
  def process(x), do: {:ok, 2 * x}
end

defmodule Fail do
  def process(_x), do: {:error, "Service error"}
end
