defmodule NonceAgent do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  def get_nonce_list(bucket) do
    Agent.get(bucket, fn state ->
      Map.keys(state)
    end)
  end

  def put(bucket, nonce) do
    Agent.update(bucket, &Map.put(&1, nonce, nonce))
  end
end
