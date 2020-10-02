require_relative 'csv_record'
require_relative 'rideable'

module RideShare
  class Passenger < CsvRecord
    include RideShare::Rideable
    attr_reader :name, :phone_number, :trips

    def initialize(id:, name:, phone_number:, trips: [])
      super(id)

      @name = name
      @phone_number = phone_number
      @trips = trips
    end


    def net_expenditures
      return ended_trips.sum{|trip| trip.cost}
    end

    def total_time_spent
      return ended_trips.sum{|trip| trip.calculate_duration}
    end

    private

    def self.from_csv(record)
      return new(
        id: record[:id],
        name: record[:name],
        phone_number: record[:phone_num]
      )
    end
  end
end
