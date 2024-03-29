require_relative('../db/sql_runner.rb')

class Customer

  attr_accessor :name, :funds
  attr_reader :id

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @name = options['name']
    @funds = options['funds']
  end

  def save
    sql = "INSERT INTO customers(name, funds)
    VALUES ($1, $2)
    RETURNING id"
    values = [@name, @funds]
    save = SqlRunner.run(sql, values)[0]
    @id = save['id'].to_i
  end

  def update
    sql = "UPDATE customers SET(name, funds) =
    ($1, $2) WHERE id = $3"
    values = [@name, @funds, @id]
    SqlRunner.run(sql, values)
  end

  def films_by_customer
    sql = "SELECT films.* FROM films
    INNER JOIN tickets
    ON tickets.film_id = films.id
    WHERE tickets.customer_id = $1"
    return Film.map_items(SqlRunner.run(sql, [@id]))
  end

  def number_of_tickets
    films = self.films_by_customer
    return films.count
  end

  def delete
    sql = "DELETE FROM customers WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def self.delete_all
    sql = "DELETE FROM customers"
    SqlRunner.run(sql, values)
  end

  def self.all
    sql = "SELECT * FROM customers"
    return Customer.map_items(SqlRunner.run(sql))
  end

  def self.map_items(items)
    return items.map { |item| Customer.new(item) }
  end
end
