GROUP INFO

Jacob Ville	        4540-7373<br>
Shaifil Maknojia	7805-9466<br>

***

#### Instructions:

1. Extract proj4_2.zip
2. Go to proj4_2 folder
3. run "mix deps.get"
4. run "mix compile"
5. run "mix phx.server" to start the server
6. run "mix proj5.exs" to run simulation
7. visit localhost:4000 to see the nonce over time
8. visit localhost:4000/transactions to see the transaction volume
9. visit localhost:4000/wallet to see the final value of each wallet
	
***

###### Transaction Scenarios

In our simulation we spawn 100 actors, each has their own wallet and has 
the ability to mine and send coins to other actors. For demonstration purposes
each actor starts with 10 coins. Then 5 transactions occur between random actors,
transferring a random number of coins. After 5 transactions, a random actor
mines a new block, which appends the previous transactions to the block and
appends it to the blockchain. Finally, the final value of each actor's wallet
is printed. 

Each of these steps are shown in the output when running "mix proj5.exs".

***

###### Tests
1. Initialize Blockchain
Calling the Blockchain.init method appends the genesis block to the blockchain.

2. Transactions do not occur when invalid
When a transaction cannot be processed due to a wallet not existing or a node not having enough coins to complete a transaction, the transaction is not recorded.

3. Transactions transfer coins when valid
A valid transaction will be recorded in the blockchain and each node will receive the correct number of coins in their wallet.

4. Mining calculates valid proof of work
Upon creating a new block by mining, the calculated hash_int is less than the target value.

5. Mining appends current transactions to block
Mining a block takes the current transactions in the blockchain and places them in the newly added block, emptying the chain's current transactions.

6. Mining appends new block to blockchain
The blockchain's length increases as blocks are added.
