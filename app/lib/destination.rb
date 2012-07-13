class Destination
  attr_reader :name, :address1, :city, :zip, :country_code, :state, :address2, :address3

  def initialize(address1, city, zip, country_code, state)
    @name = 'destination'
    @address1 = address1
    @city = city
    @zip = zip
    @country_code = country_code
    @state = state
    @address2 = nil
    @address3 = nil
  end

  def self.build_example
    destination = Destination.new('190 MacLaren Street','Ottawa','K2P 0L6','CA','Ontario')
  end
end