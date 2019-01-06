defmodule Block do
  defstruct [:timestamp, :transactions, :nonce, :hash, :prev_hash]

  def new(transactions, prev_hash) do
    new_block = %Block{
      timestamp: NaiveDateTime.utc_now() |> NaiveDateTime.to_string(),
      transactions: transactions,
      prev_hash: prev_hash
    }

    {nonce, hash} =
      new_block
      |> POW.new()
      |> POW.calculate()

    %{new_block | nonce: nonce, hash: hash}
  end

  def genesis_block do
    %Block{
      timestamp: NaiveDateTime.utc_now() |> NaiveDateTime.to_string(),
      transactions: [],
      nonce: 0,
      prev_hash: "GENESIS_BLOCK"
    }
  end

  def get_block_hash(block) do
    encoded_block = block |> Poison.encode!()
    :crypto.hash(:sha256, encoded_block) |> Base.encode16()
  end

  def put_block_hash(block) do
    %{block | hash: get_block_hash(block)}
  end
end
