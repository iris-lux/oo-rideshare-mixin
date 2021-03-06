require_relative 'test_helper'
require 'time'
# TEST_DATA_DIR = 'test/test_data'

describe "Trip class" do
  describe "initialize" do
    before do
      start_time = Time.now - 60 * 60 # 60 minutes
      end_time = start_time + 25 * 60 # 25 minutes
      @trip_data = {
        id: 8,
        passenger: RideShare::Passenger.new(
          id: 1,
          name: "Ada",
          phone_number: "412-432-7640"
        ),
        start_time: start_time,
        end_time: end_time,
        cost: 23.45,
        rating: 3,
        driver: RideShare::Driver.new(
            id: 42,
            vin: '1B6CF40K1J3Y74UY2',
            status: :UNAVAILABLE,
            name: "Roger"
        )
      }
      @trip = RideShare::Trip.new(@trip_data)
    end

    it "is an instance of Trip" do
      expect(@trip).must_be_kind_of RideShare::Trip
    end

    it "stores an instance of passenger" do
      expect(@trip.passenger).must_be_kind_of RideShare::Passenger
    end

    it "stores an instance of driver" do
      expect(@trip.driver).must_be_kind_of RideShare::Driver
    end

    it "raises an error for an invalid rating" do
      [-3, 0, 6].each do |rating|
        @trip_data[:rating] = rating
        expect do
          RideShare::Trip.new(@trip_data)
        end.must_raise ArgumentError
      end
    end

    it 'raises an error if end_time is before start_time' do
      start_time = Time.now - 60 * 60 # 60 minutes
      end_time = start_time - 25 * 60 # 25 minutes
      trip_data = {
          id: 8,
          passenger: RideShare::Passenger.new(
              id: 1,
              name: "Ada",
              phone_number: "412-432-7640"
          ),
          start_time: start_time,
          end_time: end_time,
          cost: 23.45,
          rating: 3,
          driver: RideShare::Driver.new(
              id: 42,
              vin: '1B6CF40K1J3Y74UY2',
              status: :UNAVAILABLE,
              name: "Roger")
      }
      expect{RideShare::Trip.new(trip_data)}.must_raise ArgumentError
    end

    it "check_duration returns 0 when trip is in progress" do
      @trip = RideShare::Trip.new(
          id: 11,
          passenger_id: 4,
          start_time: Time.now,
          end_time: nil,
          cost: nil,
          rating: nil,
          driver_id: 3
      )
      expect(@trip.check_duration).must_equal 0
    end

  end

  describe "from_csv" do
    before do
      @trips = RideShare::Trip.load_all(full_path: "#{TEST_DATA_DIR}/trips.csv")
    end

    it 'read in start_time and end_time as Time objects' do
      @trips.each do |trip|
        expect(trip.start_time).must_be_instance_of Time
        expect(trip.end_time).must_be_instance_of Time
      end
    end
  end

  describe "calculate duration in seconds" do

    it "returns 0 when trip is in progress" do
      @trip = RideShare::Trip.new(
          id: 11,
          passenger_id: 4,
          start_time: Time.now,
          end_time: nil,
          cost: nil,
          rating: nil,
          driver_id: 3
      )
      expect(@trip.calculate_duration).must_equal 0
    end

    it "calculated duration of trips in seconds" do
      start_time = Time.now - 60 * 60
      end_time = start_time + 25 * 60
      @trip_data = {
          id: 8,
          passenger: RideShare::Passenger.new(
              id: 1,
              name: "Ada",
              phone_number: "412-432-7640"
          ),
          start_time: start_time,
          end_time: end_time,
          cost: 23.45,
          rating: 3,
          driver: RideShare::Driver.new(
              id: 42,
              vin: '1B6CF40K1J3Y74UY2',
              status: :UNAVAILABLE,
              name: "Roger")
      }
      @trip = RideShare::Trip.new(@trip_data)
      expect(@trip.calculate_duration).must_be_close_to 1500
    end


  end


end
