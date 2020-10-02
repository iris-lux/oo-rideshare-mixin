require_relative 'test_helper'

TEST_DATA_DIRECTORY = 'test/test_data'

describe "TripDispatcher class" do
  def build_test_dispatcher
    return RideShare::TripDispatcher.new(
      directory: TEST_DATA_DIRECTORY
    )
  end

  describe "Initializer" do
    it "is an instance of TripDispatcher" do
      dispatcher = build_test_dispatcher
      expect(dispatcher).must_be_kind_of RideShare::TripDispatcher
    end

    it "establishes the base data structures when instantiated" do
      dispatcher = build_test_dispatcher

      [:trips, :passengers].each do |prop|
        expect(dispatcher).must_respond_to prop
      end

      expect(dispatcher.trips).must_be_kind_of Array
      expect(dispatcher.passengers).must_be_kind_of Array
      expect(dispatcher.drivers).must_be_kind_of Array
    end

    it "loads the development data by default" do
      # Count lines in the file, subtract 1 for headers
      trip_count = %x{wc -l 'support/trips.csv'}.split(' ').first.to_i - 1

      dispatcher = RideShare::TripDispatcher.new

      expect(dispatcher.trips.length).must_equal trip_count
    end
  end

  describe "passengers" do
    describe "find_passenger method" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "throws an argument error for a bad ID" do
        expect{ @dispatcher.find_passenger(0) }.must_raise ArgumentError
      end

      it "finds a passenger instance" do
        passenger = @dispatcher.find_passenger(2)
        expect(passenger).must_be_kind_of RideShare::Passenger
      end
    end

    describe "Passenger & Trip loader methods" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "accurately loads passenger information into passengers array" do
        first_passenger = @dispatcher.passengers.first
        last_passenger = @dispatcher.passengers.last

        expect(first_passenger.name).must_equal "Passenger 1"
        expect(first_passenger.id).must_equal 1
        expect(last_passenger.name).must_equal "Passenger 8"
        expect(last_passenger.id).must_equal 8
      end

      it "connects trips and passengers" do
        dispatcher = build_test_dispatcher
        dispatcher.trips.each do |trip|
          expect(trip.passenger).wont_be_nil
          expect(trip.passenger.id).must_equal trip.passenger_id
          expect(trip.passenger.trips).must_include trip
        end
      end
    end
  end

  describe "drivers" do
    describe "find_driver method" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "throws an argument error for a bad ID" do
        expect { @dispatcher.find_driver(0) }.must_raise ArgumentError
      end

      it "finds a driver instance" do
        driver = @dispatcher.find_driver(2)
        expect(driver).must_be_kind_of RideShare::Driver
      end
    end

    describe "Driver & Trip loader methods" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "accurately loads driver information into drivers array" do
        first_driver = @dispatcher.drivers.first
        last_driver = @dispatcher.drivers.last

        expect(first_driver.name).must_equal "Driver 1 (unavailable)"
        expect(first_driver.id).must_equal 1
        expect(first_driver.status).must_equal :UNAVAILABLE
        expect(last_driver.name).must_equal "Driver 3 (no trips)"
        expect(last_driver.id).must_equal 3
        expect(last_driver.status).must_equal :AVAILABLE
      end

      it "connects trips and drivers" do
        dispatcher = build_test_dispatcher
        dispatcher.trips.each do |trip|
          expect(trip.driver).wont_be_nil
          expect(trip.driver.id).must_equal trip.driver_id
          expect(trip.driver.trips).must_include trip
        end
      end
    end

    describe "request_trip method(Intelligent Dispatching)" do
      before do
        @dispatcher = build_test_dispatcher
        @driver = @dispatcher.find_driver(3)
      end

      it "must return trip object" do
        expect(@dispatcher.request_trip(2)).must_be_instance_of RideShare::Trip
      end

      it 'adds a trip to the trips attribute' do
        trips_before_request = @dispatcher.trips.length
        @dispatcher.request_trip(2)
        expect(@dispatcher.trips.length).must_equal(trips_before_request + 1)
      end

      it 'adds a trip to passenger when passengers id is passed' do
        passenger = @dispatcher.find_passenger(2)
        trip_count = passenger.trips.length
        @dispatcher.request_trip(2)
        expect(passenger.trips.length).must_equal (trip_count + 1)
      end

      it 'adds a trip to first available driver when request_trip is called' do
        trip_count = @driver.trips.length
        @dispatcher.request_trip(2)
        expect(@driver.trips.length).must_equal (trip_count + 1)
      end

      it 'assigns the first available driver who has never driven' do
        requested_trip = @dispatcher.request_trip(2)
        expect(@driver.id).must_equal (requested_trip.driver.id)
      end

      it 'assigns the driver who has never driven or whos most recent trip is oldest' do
        @driver.add_trip(RideShare::Trip.new(
                                              id:20,
                                              passenger_id: 2,
                                              start_time: Time.new(1998, 10, 31),
                                              end_time: Time.new(1998, 11, 1),
                                              driver: @driver,
                                              rating: 3
                                              ))
        requested_trip = @dispatcher.request_trip(2)
        expect(@driver.id).must_equal (requested_trip.driver.id)
      end

      it 'switches drivers status to unavailable' do
        @dispatcher.request_trip(2)
        expect(@driver.status).must_equal (:UNAVAILABLE)
      end

      it 'returns nil if there are no available drivers' do
        @dispatcher.request_trip(2)
        @dispatcher.request_trip(1)
        @dispatcher.request_trip(3)
        expect(@dispatcher.request_trip(3)).must_be_nil
      end
    end
  end
end

