module RideShare
  module Rideable

    def add_trip(trip)
      @trips << trip
    end

    private

    def ended_trips
      return @trips.select{|trip| !trip.end_time.nil? || !trip.cost.nil? || !trip.rating.nil?}
    end

  end
end