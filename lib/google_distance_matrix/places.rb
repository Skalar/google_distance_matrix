module GoogleDistanceMatrix
  class Places
    include Enumerable

    def initialize(places = [])
      @places = []
      concat Array.wrap(places)
    end


    delegate :each, :[], :length, :index, :pop, :shift, :delete_at, :compact, :inspect, to: :places

    [:<<, :push, :unshift].each do |method|
      define_method method do |*args|
        args = ensure_args_are_places args

        places.public_send(method, *args)

        places.uniq!
        self
      end
    end

    def concat(other)
      push *other
    end


    private

    attr_reader :places

    def ensure_args_are_places(args)
      args.map do |arg|
        if arg.is_a? Place
          arg
        else
          Place.new arg
        end
      end
    end
  end
end
