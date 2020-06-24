require_relative '../price_calculator'
require 'pry'


describe "price_calculator" do

  context "price calculation with valid input" do


    it "should return total" do
      items_price = PriceCalculator.new(["A", "B"]).generate
      expect(items_price.keys.to_s).to include("total")
      expect(items_price[:total].keys.to_s).to include('discounted_cost')
      expect(items_price[:total].keys.to_s).to include('actual_cost')
      expect(items_price[:total][:discounted_cost]).to eq 50.0
      expect(items_price[:total][:actual_cost]).to eq 50.0
    end

    it "should return quantity of each item" do
      check_quantity = PriceCalculator.new(["A", "B"]).check_quantity(["A", "B"])
      expect(check_quantity["A"]).to eq 1
      expect(check_quantity["B"]).to eq 1
    end

    it "should return unit price with respect to quantity" do
      check_price = PriceCalculator.new(["A", "B"]).price_items
      expect(check_price[:A].keys.to_s).to include('unit_price')
      expect(check_price[:A].keys.to_s).to include('sale')
      expect(check_price[:B].keys.to_s).to include('unit_price')
      expect(check_price[:B].keys.to_s).to include('sale')
      expect(check_price[:C].keys.to_s).to include('unit_price')
      expect(check_price[:D].keys.to_s).to include('unit_price')
    end
  end
end
