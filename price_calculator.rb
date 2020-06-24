# frozen_string_literal: true
require 'pry'
# Class for calculating the price of items.
class PriceCalculator
  attr_reader :items

  def initialize(items)
    @items = items

    calculate
  end

  def calculate
    item_quantity = group_items_by_quantity(items)

    item_price = item_quantity.each_with_object({}) do |item, cart|
      product = item.first.to_sym
      quantity = item.last
      cart[product] = calculate_price(product, quantity).merge(quantity: quantity)
    end

    {
      total: calculate_total_amounts(item_price.values),
      items: item_price
    }
  end

  def calculate_total_amounts(item_price)
    item_price.each_with_object(Hash.new(0.0)) do |item, final|
      final[:discounted_price] += item[:discounted_price]
      final[:actual_price] += item[:actual_price]
    end
  end

  def group_items_by_quantity(items)
    items.group_by(&:itself).transform_values(&:count)
  end

  def promotions
    {
      A: { unit_price: 30, discount: { qty: 3, new_price: 75} },
      B: { unit_price: 20, discount: { qty: 2, new_price: 35 } },
      C: { unit_price: 50 },
      D: { unit_price: 15 }
    }
  end

  def calculate_price(item, quantity)

    price = promotions[item]

    cost = { actual_price: price[:unit_price] * quantity }

    return cost.merge(discounted_price: cost[:actual_price]) unless price[:discount] && price[:discount][:qty] <= quantity

    cost[:discounted_price] = discounted_price(item, quantity)
    cost
  end

  def discounted_price(item, quantity)
    price = promotions[item]
    if quantity % price[:discount][:qty] != 0
      unit_quantity = quantity % price[:discount][:qty]
      price[:unit_price] * unit_quantity + price[:discount][:new_price]
    elsif quantity % price[:discount][:qty] == 0
      unit_quantity = quantity / price[:discount][:qty]
      price[:discount][:new_price] * unit_quantity
    end 
  end
end

# Executes the programs from here

puts 'items          Price'
puts '-------------------'

puts "A\t\t $30"
puts "B\t\t $20"
puts "C\t\t $50"
puts "D\t\t $15"

puts 'Please enter all the items purchased separated by a comma:'
items = gets.chomp.upcase.split(',').collect(&:strip)
item_price = PriceCalculator.new(items).calculate
puts "\n"
puts 'Items         Quantity          Price'
puts '-------------------------------------'
item_price[:items].each do |item, _value|
  items = item_price[:items][item]
  puts "#{item}\t\t #{items[:quantity]}\t\t $#{items[:discounted_price]}"
  puts "\n"
end
item_actual_total = item_price[:total][:actual_price]
item_discount_total = item_price[:total][:discounted_price]
discount_for_basket_value = item_discount_total > 150 ? 20 : 0
puts "Total price: $#{item_discount_total - discount_for_basket_value}"
puts "You saved $#{(item_actual_total - (item_discount_total - discount_for_basket_value)).round(2)} today."