defmodule Proj42Web.PageController do
  use Proj42Web, :controller

  def index(conn, _params) do
    chain = Blockchain.init()

    Enum.each(1..100, fn actor_no ->
      Node.start_link(actor_no)
    end)

    create_transaction(144, 5, chain, [], conn)
  end

  def create_transaction(num, block_size, chain, nonce_list, conne) do
    if(num > 0) do
      sender = Enum.random(1..100) |> Integer.to_string()
      receiver = Enum.random(1..100) |> Integer.to_string()

      sender_p_id = GenServer.whereis(:"#{sender}")
      find_sender_balance = GenServer.call(sender_p_id, :peek)

      amount = Enum.random(1..find_sender_balance)

      chain = Blockchain.new_transaction(chain, sender, receiver, amount)

      # IO.puts "Transaction #{num} completed, Actor no #{sender} sent #{amount}-BTC to Actor no #{receiver}"
      [chain, b, nonce_list] = check_block_creation(block_size - 1, num, chain, nonce_list)

      create_transaction(num - 1, b, chain, nonce_list, conne)
    else
      # IO.puts "****** SIMULATED N TRANSACTIONS SUCCESSFULLY!! *********"
      IO.inspect(nonce_list)
      render_nonce_page(nonce_list, conne)
    end
  end

  def check_block_creation(b_size, n, chain, nonce_tracker) do
    miner_number = Enum.random(1..100) |> Integer.to_string()
    miner_pid = GenServer.whereis(:"#{miner_number}")

    [chain, b_size, list_of_nonce_values] =
      cond do
        b_size == 0 ->
          chain = GenServer.call(miner_pid, {:mine, chain}, :infinity)
          nonce_tracker = nonce_tracker ++ [hd(chain.chain).nonce]
          [chain, 5, nonce_tracker]

        n == 1 ->
          chain = GenServer.call(miner_pid, {:mine, chain}, :infinity)
          nonce_tracker = nonce_tracker ++ [hd(chain.chain).nonce]
          [chain, 0, nonce_tracker]

        true ->
          # nonce_tracker = [nonce_tracker] ++ hd(chain.chain).nonce
          [chain, b_size, nonce_tracker]
      end

    [chain, b_size, list_of_nonce_values]
  end

  def render_nonce_page(final_list, connection) do
    list_1 = 1..length(final_list)
    labels = list_1 |> Enum.to_list()

    html(connection, """
                  <style>
                  .button1 {font-size: 15px;
              background-color: #4CAF50;
              border: none;
              color: white;
              padding: 15px 32px;
              text-align: center;
              text-decoration: none;
              display: inline-block;
              margin: 4px 2px;
              cursor: pointer;
              }
              .chart-container {
                width: 1000px;
                height:500px
            }
            </style>
            <center><div class="chart-container">
            <canvas id="myChart"></canvas>
            </div>
            </center>
                <center><button type="button" class="button1" onclick="myFunction()"><b>Show effort spent</b></button></center>
                <p id="demo"></p>
       <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.3/Chart.js"></script>
    <script>
    var ctx = document.getElementById("myChart");
    var myChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: #{inspect(labels, limit: :infinity)},
        datasets: [{
          label: 'Nonce values',
          backgroundColor: "rgba(155, 89, 182,0.2)",
          borderColor: "rgba(142, 68, 173,1.0)",
          pointBackgroundColor: "rgba(142, 68, 173,1.0)",
          data: #{inspect(final_list, limit: :infinity)}
        }]
      }
            });
            function myFunction()
    {
      document.getElementById("demo").innerHTML = "<h4><b><i>Nonce Values given below </i><b><h4>"+#{
      inspect(final_list, limit: :infinity)
    };
    }
             </script>
         </html>
    """)
  end
end
