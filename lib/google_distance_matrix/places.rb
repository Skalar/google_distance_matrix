module GoogleDistanceMatrix
  class Places
    include Enumerable

    def initialize(places = [])
      @places = []
      concat Array.wrap(places)
    end


    delegate :each, :[], :length, to: :places

    [:<<, :concat].each do |method|
      define_method method do |*args|
        places.public_send method, *args
        places.uniq!
      end
    end



    private

    attr_reader :places
  end
end
