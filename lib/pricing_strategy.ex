defprotocol ElasticPriceEngine.PricingStrategy do
  @doc "common interface for pulling the amount whether the state is simple or complex"
  def amount(state)

  @doc false
  def count(state)

  @doc false
  def increment(state)

  @doc false
  def decrement(state)
end
