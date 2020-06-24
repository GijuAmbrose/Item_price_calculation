require_relative '../price_calculator'
require 'pry'


describe "price_calculator" do

  context "price calculation with valid input" do
    let!(:multiple_Aes) { PriceCalculator.new(["A", "A", "B"]) }
    let!(:multiple_Bes) { PriceCalculator.new(["A", "B", "B"]) }

    it "should return quantity of each item" do
      item_quantity = multiple_Aes.group_items_by_quantity(["A", "A", "B"])
      expect(item_quantity["A"]).to eq 2
      expect(item_quantity["B"]).to eq 1
    end


    it "should calculate the discounts for A correctly" do
      quantity = multiple_Aes.group_items_by_quantity(["A", "A", "B"])
      promotions = multiple_Aes.promotions
      if promotions[:A][:qty] == quantity["A"]
        expect(promotions[:A][:new_price]).to eq 75
      else
        expect(promotions[:A][:new_price]).to eq nil
      end
    end

    it "should calculate the discounts for B correctly" do 
      quantity = multiple_Bes.group_items_by_quantity(["A", "A", "B"])
      promotions = multiple_Aes.promotions
      if promotions[:B][:qty] == quantity["B"]
        expect(promotions[:B][:new_price]).to eq 35
      else
        expect(promotions[:B][:new_price]).to eq nil
      end
    end

    it "should return unit price with respect to quantity" do
      check_price = multiple_Aes.promotions
      expect(check_price[:A].keys.to_s).to include('unit_price')
      expect(check_price[:A].keys.to_s).to include('discount')
      expect(check_price[:B].keys.to_s).to include('unit_price')
      expect(check_price[:B].keys.to_s).to include('discount')
      expect(check_price[:C].keys.to_s).to include('unit_price')
      expect(check_price[:D].keys.to_s).to include('unit_price')
    end

    it "should return the correct total" do
      items_price = multiple_Aes.calculate
      expect(items_price.keys.to_s).to include("total")
      expect(items_price[:total].keys.to_s).to include('discounted_price')
      expect(items_price[:total].keys.to_s).to include('actual_price')
      expect(items_price[:total][:discounted_price]).to eq 80.0
      expect(items_price[:total][:actual_price]).to eq 80.0
    end

  end
end
