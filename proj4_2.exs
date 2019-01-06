chain = Blockchain.init()

Enum.each(1..100, fn actor_no ->
  Node.start_link(actor_no)
end)

PerformTransaction.create_transaction(74, 5, chain)
