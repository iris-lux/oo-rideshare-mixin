require_relative 'csv_record'

module RideShare
  class Driver < CsvRecord
    attr_reader :name, :vin, :status, :trips

    def initialize(id:, name:, vin:, status: :AVAILABLE, trips: [])
      super(id)

      if vin.length != 17
        raise ArgumentError.new("Invalid VIN number.")
      end

      @name = name
      @vin = vin
      @status = status
      @trips = trips
    end

    private

    def self.from_csv(record)
      return self.new(
          id: record[:id],
          name: record[:name],
          vin: record[:vin],
          status: record[:status]
      )
    end

  end



end
