class CardComparator
  
  # here we use a SuperMemo2 algorithm
  # to read more about it, follow the link https://www.supermemo.com/english/ol/sm2.htm

  def initialize(params)
    @card = params[:card]
    @compared_text = params[:compared_text]
  end

  def self.call(params)
  	 Result.new(new(params).diff)
  end

  def diff
  	difference = DamerauLevenshtein.distance(@card.original_text.downcase.strip, @compared_text.downcase.strip, 1, 2)
    if  difference == 0     # until we have no jQuery timer, we think all answer "perfectly correct"
      @q = 5    
  	elsif difference == 1   # incorrect answer with a little error
      @q = 2
    elsif difference == 2   # incorrect answer with rather significant error
      @q = 1
    elsif difference >= 3   # absolytely incorrect answer
      @q = 0
  	end
    review_date_calc
    return difference
  end

  def review_date_calc
    if @q < 3
      @card.update(repeate: 1, review_date: 1.day.from_now, interval: 1)
    else
      interval_calc
      @card.update(repeate: @card.repeate + 1, review_date: @card.interval.days.from_now)
    end
  end

  def interval_calc
    if @card.repeate == 1
      @card.update(interval: 1)
    elsif @card.repeate == 2
      @card.update(interval: 6)
    elsif @card.repeate >= 3
      @card.update(interval: @card.interval*efactor)
    end
  end

  def efactor
    if new_efactor = @card.e_factor-0.8+0.28*@q-0.02*@q*@q < 1.3   # read about SuperMemo2 here https://www.supermemo.com/english/ol/sm2.htm
      return new_efactor = 1.3
    else
      return new_efactor
    end
  end
end