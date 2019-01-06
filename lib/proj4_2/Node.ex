defmodule Node do
  use GenServer

  def start_link(node_no) do
    GenServer.start_link(__MODULE__, node_no, name: :"#{node_no}")
  end

  def init(node_no) do
    # node_no, number_of_coins
    {:ok, {node_no, 10}}
  end

  def handle_call(:peek, _from, {node_no, value}) do
    {:reply, value, {node_no, value}}
  end

  def handle_call({:mine, chain}, _from, state) do
    {n, wallet_value} = state
    # IO.puts("Node #{n} mining")

    chain = Blockchain.new_block(chain)
    IO.puts("\n **** Node #{n} mined the new block and received 5 BTC as reward ****\n")
    {:reply, chain, {n, wallet_value + 5}}
  end

  def handle_cast({:update_wallet, amount}, state) do
    {n, wallet_value} = state
    {:noreply, {n, wallet_value + amount}}
  end
end
