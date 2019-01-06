defmodule Proj42Web.TransactionsController do
  use Proj42Web, :controller

  def index(conn, _params) do
    chain = Blockchain.init()

    Enum.each(1..100, fn actor_no ->
      Node.start_link(actor_no)
    end)

    create_transaction(120, 5, chain, [], conn)
  end

  def create_transaction(num, block_size, chain, amount_list, conne) do
    if(num > 0) do
      sender = Enum.random(1..100) |> Integer.to_string()
      receiver = Enum.random(1..100) |> Integer.to_string()

      sender_p_id = GenServer.whereis(:"#{sender}")
      find_sender_balance = GenServer.call(sender_p_id, :peek)

      amount = Enum.random(1..find_sender_balance)
      chain = Blockchain.new_transaction(chain, sender, receiver, amount)
      amount_list = amount_list ++ [amount]

      # IO.puts "Transaction #{num} completed, Actor no #{sender} sent #{amount}-BTC to Actor no #{receiver}"

      [chain, b] = check_block_creation(block_size - 1, num, chain)

      create_transaction(num - 1, b, chain, amount_list, conne)
    else
      # IO.puts "****** SIMULATED N TRANSACTIONS SUCCESSFULLY!! *********"
      IO.inspect(amount_list)
      render_page(amount_list, conne)
    end
  end

  def render_page(final_list, connection) do
    list_1 = 1..length(final_list)
    labels = list_1 |> Enum.to_list()

    html(connection, """
                      <style>
                    .button1 {font-size: 15px;
                              background-color: #008CBA;
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
                                width: 2000px;
                                height:500px
                            }
                            </style>
                            <div class="chart-container">
                            <canvas id="myChart"></canvas>
                            </div>
      <center><button type="button" class="button1" onclick="myFunction()"><b>Show Transactions!! </b></button></center>
      <p id="demo"></p>


       <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.3/Chart.js"></script>
    <script>
    var ctx = document.getElementById("myChart");
    var myChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: #{inspect(labels, limit: :infinity)},
            datasets: [{
                label: 'Number of BTC transferred in Each transaction',
                backgroundColor: "rgba(55, 189, 82,0.7)",
                borderColor: "rgba(42, 168, 133,0.5)",
                pointBackgroundColor: "rgba(142, 68, 173,1.0)",
                data: #{inspect(final_list, limit: :infinity)},
                borderWidth: 1
            }]
        },
        options:
        {
          responsive: true,
          maintainAspectRatio: false,
          scales:{
            xAxes: [{
              // Change here
            barPercentage: 0.9,
            categoryPercetange: 0.9
          }]
          }
        }
    });

    function myFunction()
    {
      document.getElementById("demo").innerHTML = "<h3><b><i>BTC Transacted Given Below </i><b><h3>"+#{
      inspect(final_list, limit: :infinity)
    };
    }
    </script>
    """)
  end

  def check_block_creation(b_size, n, chain) do
    miner_number = Enum.random(1..100) |> Integer.to_string()
    miner_pid = GenServer.whereis(:"#{miner_number}")

    [chain, b_size] =
      cond do
        b_size == 0 ->
          chain = GenServer.call(miner_pid, {:mine, chain}, :infinity)
          [chain, 5]

        n == 1 ->
          chain = GenServer.call(miner_pid, {:mine, chain}, :infinity)
          [chain, 0]

        true ->
          [chain, b_size]
      end

    [chain, b_size]
  end
end
