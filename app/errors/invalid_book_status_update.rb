class InvalidBookStatusUpdate < StandardError
  attr_reader :details

  def initialize(details)
    @details = details
    super(details.join(", "))
  end
end