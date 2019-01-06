defmodule POW do
  use Bitwise, only_operators: true
  defstruct [:target_value, :block_input]

  @target_manipulator 12
  @upper_limit 50_000_000_000_000_000

  def new(block) do
    # Target set to 15 for faster mining
    left_shift = 1 <<< (256 - @target_manipulator)

    %POW{
      block_input: block,
      target_value: left_shift
    }
  end

  def calculate(%POW{} = work_on) do
    # IO.puts("\nMining block with transactions: \n#{inspect(work_on.block_input.transactions)}\n")
    find_appropriate_nonce(work_on, 0)
  end

  def find_appropriate_nonce(%POW{} = pow, nonce) when nonce < @upper_limit do
    bin_data = POW.data_to_binary(pow, nonce)
    hash = :crypto.hash(:sha256, bin_data) |> Base.encode16()
    {hash_int, _} = hash |> Integer.parse(16)

    if hash_int > pow.target_value do
      find_appropriate_nonce(pow, nonce + 1)
    else
      {nonce, hash}
    end
  end

  def data_to_binary(%POW{} = proof_of_work, nonce) do
    prev_hash = get_previous_blocks_hash(proof_of_work)
    transactions = get_transactions_from_block(proof_of_work)
    transactions = transactions |> Poison.encode!()
    timestamp = get_timestamp(proof_of_work)
    target_manipulator = get_target_manipulator()

    <<
      prev_hash::binary,
      transactions::binary,
      timestamp::binary,
      target_manipulator::binary,
      Integer.to_string(nonce, 16)::binary
    >>
  end

  def get_previous_blocks_hash(%POW{} = proof_of_work) do
    proof_of_work.block_input.prev_hash
  end

  def get_transactions_from_block(%POW{} = proof_of_work) do
    proof_of_work.block_input.transactions
  end

  def get_timestamp(%POW{} = proof_of_work) do
    proof_of_work.block_input.timestamp |> to_string
  end

  def get_target_manipulator do
    Integer.to_string(@target_manipulator, 16)
  end
end
