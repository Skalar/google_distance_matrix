module GoogleDistanceMatrix
  class Places
    include Enumerable

    def initialize(places = [])
      @places = []
      concat Array.wrap(places)
    end


    delegate :each, :[], :length, :index, :pop, :shift, :delete_at, :compact, to: :places

    [:<<, :concat, :push, :unshift, :insert].each do |method|
      define_method method do |*args|
        places.public_send(method, *args).tap do
          places.uniq!
        end
      end
    end



    private

    attr_reader :places
  end
end
