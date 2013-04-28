# GoogleDistanceMatrix

Ruby client for The Google Distance Matrix API.

This lib makes Google's distance matrix API easy to work with,
allowing you to set up some origins and destinations and
pull the distance matrix from Google.

Once you have the matrix you can fetch all routes from a given
origin or to a given destination.

The matrix may also be used as a data set for traveling salesman problem,
but to solve it you may look at http://ai4r.org/.




## Examples

    # Set up a matrix to work with
    matrix = GoogleDistanceMatrix::Matrix.new

    # Create some places to be used as origins or destinations for the matrix
    lat_lng = GoogleDistanceMatrix::Place.new lng: 12, lat: 12
    address = GoogleDistanceMatrix::Place.new address: "My address, Oslo"
    dest_address = GoogleDistanceMatrix::Place.new address: "Home, Oppegaard"

    point_dest = Point.new lat: 1, lng: 2
    dest_object = GoogleDistanceMatrix::Place.new point_dest

    # Add places to matrix's origins and destinations
    matrix.origins << lat_lng << address
    matrix.destinations << dest_address << dest_object

    # Added objects will be wrapped in a place automatically, so you may skip manyally creating Places.
    another_point = Point.new lat: 1, lng: 3
    matrix.origins << another_point

    # Do some configuration - see GoogleDistanceMatrix.default_configuration as well.
    matrix.configure do |config|
      config.mode = 'driving'
      config.avoid = ['tolls']

      # To build signed URLs to use with a Google Business account
      config.google_business_api_client_id = "123"
      config.google_business_api_private_key = "your-secret-key"
    end

    # Returns the data, loaded from Google, for this matrix.
    # It is a multi dimensional array. Rows are ordered according to the values in the origins.
    # Each row corresponds to an origin, and each element within that row corresponds to
    # a pairing of the origin with a destination.
    matrix.data

    # Returns an array of Google::DistanceMatrix::Route, all having given origin or destination.
    matrix.routes_for dest_address

    # Returns Google::DistanceMatrix::Route with given origin and destination
    matrix.route_for origin: lat_lng, destination: dest_address

    matrix.shortest_route_by_distance_to(dest_address) # returns Google::DistanceMatrix::Route with one origin and a destination, together with route data
    matrix.shortest_route_by_duration_to(dest_address) # returns Google::DistanceMatrix::Route with one origin and a destination, together with route data

    # In cases you built the place with an object (not hash with attributes) you may provide that object
    # as well asking for routes. This is true for route_for and shortest_route_by_* as well.
    matrix.routes_for point_dest # Returns routes for dest_object





## Installation

Add this line to your application's Gemfile:

    gem 'google_distance_matrix'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install google_distance_matrix




## TODO

* Error handling in routes when status is not OK.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
