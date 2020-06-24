# frozen_string_literal: true

require 'pry'

# class for calculating the price of items.
class PriceCalculator
  attr_reader :items

  def initialize(items)
    @items = items

    generate
  end

  def generate
    item_quantity = check_quantity(items)

    item_price = item_quantity.each_with_object({}) do |item, acc|
      type = item.first.to_sym
      quantity = item.last
      acc[type] = calculate_price(type, quantity).merge(quantity: quantity)
    end

    {
      total: calculate_total_amounts(item_price.values),
      items: item_price
    }
  end

  def calculate_total_amounts(item_price)
    item_price.each_with_object(Hash.new(0.0)) do |item, final|
      final[:discounted_cost] += item[:discounted_cost]
      final[:actual_cost] += item[:actual_cost]
    end
  end

  def check_quantity(items)
    items.group_by(&:itself).transform_values(&:count)
  end

  def price_items
    {
      A: { unit_price: 30, sale: { price: 75, n: 3 } },
      B: { unit_price: 20, sale: { price: 35, n: 2 } },
      C: { unit_price: 50 },
      D: { unit_price: 15 }
    }
  end

  def calculate_price(item, quantity)
    price = price_items[item]
    cost = { actual_cost: price[:unit_price] * quantity }

    return cost.merge(discounted_cost: cost[:actual_cost]) unless price[:sale] && price[:sale][:n] == quantity

    cost[:discounted_cost] = discounted_price(item, quantity)
    cost
  end

  def discounted_price(item, quantity)
    price = price_items[item]
    unit_quantity = quantity % price[:sale][:n]

    price[:unit_price] * unit_quantity + price[:sale][:price]
  end
end

puts 'Please enter all the items purchased separated by a comma:'
items = gets.chomp.split(',').collect(&:strip)
item_price = PriceCalculator.new(items).generate
puts "\n"
puts 'Item          Quantity          Price'
puts '-------------------------------------'
item_price[:items].each do |item, _value|
  items = item_price[:items][item]
  puts "#{item}\t\t #{items[:quantity]}\t\t $#{items[:discounted_cost]}"
  puts "\n"
end
item_actual_total = item_price[:total][:actual_cost]
item_discount_total = item_price[:total][:discounted_cost]
discount_for_basket_value = item_discount_total > 150 ? 20 : 0
puts "Total price: $#{item_discount_total - discount_for_basket_value}"
puts "You saved $#{(item_actual_total - (item_discount_total - discount_for_basket_value)).round(2)} today."