class SportYear
  attr_reader :year

  def initialize(date = Date.current)
    @date = date
    @year = calculate_sport_year
  end

  def start_date
    Date.new(@year, 9, 1)
  end

  def end_date
    Date.new(@year + 1, 8, 31)
  end

  def self.current
    new(Date.current)
  end

  private

  def calculate_sport_year
    @date.month >= 9 ? @date.year : @date.year - 1
  end
end
