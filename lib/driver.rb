require_relative 'csv_record'
require_relative 'rideable'

module RideShare
    class Driver < CsvRecord
      include RideShare::Rideable

      attr_reader :name, :vin, :status, :trips

      def initialize(id:, name:, vin:, status: :AVAILABLE, trips: [])
        super(id)

        raise ArgumentError.new("Invalid VIN number.") unless vin.length == 17
        raise ArgumentError.new("Invalid status") unless [:AVAILABLE, :UNAVAILABLE].include?(status)

        @name = name
        @vin = vin
        @status = status
        @trips = trips
      end

      def average_rating
        return ended_trips.empty? ? 0 : ended_trips.sum{|trip| trip.rating.to_f}/ended_trips.length
      end

      def total_revenue
        after_fee_costs = 0

        ended_trips.each do |trip|
          after_fee_costs += (trip.cost - 1.65) if trip.cost > 1.65
        end

        return after_fee_costs * 0.8
      end

      def make_unavailable
        @status = :UNAVAILABLE
      end

      private

      def self.from_csv(record)
      return self.new(
          id: record[:id],
          name: record[:name],
          vin: record[:vin],
          status: record[:status].to_sym
      )
      end

    end

end
