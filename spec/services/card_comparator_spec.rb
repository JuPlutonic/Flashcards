require "rails_helper"
require "helpers"
require "spec_helper"

  describe CardComparator do
  	before :each do
      user = create(:user, email: "someemail2@mail.ru", password: "somepassword", password_confirmation: "somepassword")
      deck = create(:deck, user: user, name: "somename")
      @card = card_new("mom", "мама")
      @card.save
      @comparator = CardComparator.new(card: @card, compared_text: "mom")
    end

    context "#qualify method" do
      before do
        @card = card_new("something1", "somethingelse")
      end

      it "#qualify must return 5 if texsts is equal" do
        comparator = CardComparator.new(card: @card, compared_text: "something1")
        expect(@comparator.qualify).to be 5
      end

      it "#qualify must return 2 if texsts have between 1..10% type errors" do
        comparator = CardComparator.new(card: @card, compared_text: "something2")
        expect(comparator.qualify).to be 2
      end

      it "#qualify must return 1 if texsts have between 11..20% type errors" do
        comparator = CardComparator.new(card: @card, compared_text: "somethinT2")
        expect(comparator.qualify).to be 1
      end

      it "#qualify must return 0 if texsts is not equal" do
        comparator = CardComparator.new(card: @card, compared_text: "dsafewtrfa")
        expect(comparator.qualify).to be 0
      end      
    end

    context "#review_date_calc" do
      
      it "must return a hash with repeate:, review_date: and interval: if q < 3" do
        @card.repeate = 4
        @card.interval = 6
        ef_old = @card.e_factor
        expect(@comparator.review_date_calc(2)).to include(repeate: 1)
        expect(@comparator.review_date_calc(2)).to include(:review_date)        
        expect(@comparator.review_date_calc(2)).to include(interval: 1)
      end

      it "must return a hash with repeate:, review_date:, e_factor: and interval: if q >= 3" do
        @card.repeate = 4
        @card.interval = 6
        expect(@comparator.review_date_calc(5)).to include(repeate: @card.repeate+1)
        expect(@comparator.review_date_calc(5)).to include(:review_date)        
        expect(@comparator.review_date_calc(5)).to include(:interval)
        expect(@comparator.review_date_calc(5)).to include(:e_factor)
      end
    end
    context "#interval_calc" do
     
      it "must return 1 if repeate = 1, interval and efactor is no affect" do
        expect(@comparator.interval_calc( 6, 2.5, 1 )).to be == 1
      end

      it "must return 6 if repeate = 2, interval and efactor is no affect" do
        expect(@comparator.interval_calc( 6, 2.5, 2 )).to be == 6
      end

      it "must return interval * efactor if repeate = 3, interval = 6 and efactor is 2.5" do
        expect(@comparator.interval_calc( 6, 2.5, 3 )).to be == 6*2.5
      end
    end

    context "#efactor_calc" do
      before do
        @old_efactor = @card.e_factor
      end
      it "must return efactor greater than it was if q = 5 " do
        q = 5
        expect(@comparator.efactor_calc(q, @card.e_factor)).to be > @old_efactor
      end
      it "must make efactor near the same than it was if q = 4 " do
        q = 4
        expect(@comparator.efactor_calc(q, @card.e_factor).round(1)).to be == @old_efactor
      end
      it "must make efactor smaller than it was if q = 3 " do
        q = 3
        expect(@comparator.efactor_calc(q, @card.e_factor)).to be < @old_efactor
      end
    end

    context "#CardComparator" do
      
      before do
        @card = card_new("something1", "somethingelse")
      end

      it ".call must return result.success? = true if texts is equal" do
        result = CardComparator.call(card: @card, compared_text: "something1")
        expect(result.success?).to be true
      end
      it ".call must return result.type_error? = true if texts have 1..10% error" do
        result = CardComparator.call(card: @card, compared_text: "something2")
        expect(result.type_error?).to be true
      end
      it ".call must return result.type_error? = true if texts have 11..20% error" do
        result = CardComparator.call(card: @card, compared_text: "somethinT2")
        expect(result.type_error?).to be true
      end
      it ".call must return result.wrong = true if texts is not equal" do
        result = CardComparator.call(card: @card, compared_text: "dad")
        expect(result.wrong?).to be true
      end
    end

    context "#get_quality" do
      it "must return 5 if no type errors" do
        expect(@comparator.get_quality(0, 10)).to be 5
      end
      it "must return 2 if 1..10% errors" do
        expect(@comparator.get_quality(1, 10)).to be 2
      end
      it "must return 1 if 11..20% errors" do
        expect(@comparator.get_quality(2, 10)).to be 1
      end
      it "must return 5 if more than 20% errors" do
        expect(@comparator.get_quality(3, 10).to_i).to be 0
      end
    end

  end