require_relative 'test_helper'

describe "Passenger class" do

  describe "Passenger instantiation" do
    before do
      @passenger = RideShare::Passenger.new(id: 1, name: "Smithy", phone_number: "353-533-5334")
    end

    it "is an instance of Passenger" do
      expect(@passenger).must_be_kind_of RideShare::Passenger
    end

    it "throws an argument error with a bad ID value" do
      expect do
        RideShare::Passenger.new(id: 0, name: "Smithy")
      end.must_raise ArgumentError
    end

    it "sets trips to an empty array if not provided" do
      expect(@passenger.trips).must_be_kind_of Array
      expect(@passenger.trips.length).must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :phone_number, :trips].each do |prop|
        expect(@passenger).must_respond_to prop
      end

      expect(@passenger.id).must_be_kind_of Integer
      expect(@passenger.name).must_be_kind_of String
      expect(@passenger.phone_number).must_be_kind_of String
      expect(@passenger.trips).must_be_kind_of Array
    end
  end


  describe "trips property" do
    before do
      # TODO: you'll need to add a driver at some point here.
      @passenger = RideShare::Passenger.new(
        id: 9,
        name: "Merl Glover III",
        phone_number: "1-602-620-2330 x3723",
        trips: []
        )
      trip = RideShare::Trip.new(
        id: 8,
        driver_id: 11,
        passenger: @passenger,
        start_time: Time.new(2016, 8, 8),
        end_time: Time.new(2016, 8, 9),
        rating: 5
        )

      @passenger.add_trip(trip)
    end

    it "each item in array is a Trip instance" do
      @passenger.trips.each do |trip|
        expect(trip).must_be_kind_of RideShare::Trip
      end
    end

    it "all Trips must have the same passenger's passenger id" do
      @passenger.trips.each do |trip|
        expect(trip.passenger.id).must_equal 9
      end
    end
  end

  describe "net_expenditures" do
    # You add tests for the net_expenditures method
    before do
      @passenger = RideShare::Passenger.new(
        id: 1,
        name: "Ada",
        phone_number: "412-432-7640"
      )
      @trips = [{
        id: 10,
        driver_id: 11,
        passenger: @passenger,
        start_time: Time.now - 60,
        end_time: Time.now,
        cost: 23.45,
        rating: 3
        },
            {
        id: 8,
        driver_id: 11,
        passenger: @passenger,
        start_time: Time.now - 60,
        end_time: Time.now,
        cost: 26.55,
        rating: 3
        }]
    end
    it 'accurately adds up the costs of trips' do

      @trips.each{|trip| @passenger.add_trip(RideShare::Trip.new(trip))}

      expect(@passenger.net_expenditures).must_equal 50
    end

    it 'if there are no trips, returns 0' do
      expect(@passenger.net_expenditures).must_equal 0
    end
  end

  describe "total_time_spent" do
    before do
      @passenger = RideShare::Passenger.new(
          id: 1,
          name: "Ada",
          phone_number: "412-432-7640"
      )

      @trips = [{
                    id: 10,
                    driver_id: 2,
                    passenger: @passenger,
                    start_time: Time.now - 25 * 60,
                    end_time: Time.now,
                    cost: 23.45,
                    rating: 3
                },
                {
                    id: 8,
                    driver_id: 2,
                    passenger: @passenger,
                    start_time: Time.now - 25 * 60,
                    end_time: Time.now,
                    cost: 26.55,
                    rating: 3
                }]
    end
    it 'accurately adds up the times of the trips' do

      @trips.each{|trip| @passenger.add_trip(RideShare::Trip.new(trip))}

      expect(@passenger.total_time_spent).must_be_close_to 3000
    end

    it 'if there are no trips, returns 0' do
      expect(@passenger.total_time_spent).must_equal 0
    end

  end

  describe "ignore in-progress trips for calculating cost and time" do
    before do
      @trip = RideShare::Trip.new(
        id: 11,
        passenger_id: 4,
        start_time: Time.now,
        end_time: nil,
        cost: nil,
        rating: nil,
        driver_id: 3
       )
      @passenger = RideShare::Passenger.new(
          id: 1,
          name: "Ada",
          phone_number: "412-432-7640"
      )
      @passenger.add_trip(@trip)
    end

    it 'should not calculate the cost of a in-progress trip' do
      expect(@passenger.net_expenditures).must_equal 0
    end

    it 'should not calculate the time of a in-progress trip' do
      expect(@passenger.total_time_spent).must_equal 0
    end

  end
end
