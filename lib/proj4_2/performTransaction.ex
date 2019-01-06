defmodule PerformTransaction do
  def create_transaction(num, block_size, chain) do
    if(num > 0) do
      sender = Enum.random(1..100) |> Integer.to_string()
      receiver = Enum.random(1..100) |> Integer.to_string()

      sender_p_id = GenServer.whereis(:"#{sender}")
      find_sender_balance = GenServer.call(sender_p_id, :peek)

      amount = Enum.random(1..find_sender_balance)
      chain = Blockchain.new_transaction(chain, sender, receiver, amount)

      IO.puts(
        "Transaction #{num} completed, Actor no #{sender} sent #{amount}-BTC to Actor no #{
          receiver
        }"
      )

      [chain, b] = check_block_creation(block_size - 1, num, chain)

      create_transaction(num - 1, b, chain)
    else
      IO.puts(
        "\n ****** SIMULATED N TRANSACTIONS SUCCESSFULLY!! FINAL WALLET OF ACTORS IS GIVEN BELOW********* \n"
      )

      Enum.each(1..100, fn actor_no ->
        # Node.start_link(actor_no)
        node = GenServer.whereis(:"#{actor_no}")
        IO.puts("Actor #{actor_no} - #{inspect(GenServer.call(node, :peek))}")
      end)

      exit(:normal)
    end
  end

  def check_block_creation(b_size, n, chain) do
    miner_number = Enum.random(1..100) |> Integer.to_string()
    miner_pid = GenServer.whereis(:"#{miner_number}")

    [chain, b_size] =
      cond do
        b_size == 0 ->
          IO.puts("\n****** MINING NEW BLOCK ********")
          chain = GenServer.call(miner_pid, {:mine, chain}, :infinity)
          # IO.puts("****** BELOW IS THE UPDATED BLOCK CHAIN ********\n")
          # IO.inspect(chain)
          [chain, 5]

        n == 1 ->
          IO.puts("\n****** MINING FINAL BLOCK ********")
          chain = GenServer.call(miner_pid, {:mine, chain}, :infinity)
          # IO.puts("****** BELOW IS THE FINAL BLOCK CHAIN ********\n")
          # IO.inspect(chain)
          [chain, 0]

        true ->
          [chain, b_size]
      end

    [chain, b_size]
  end
end
