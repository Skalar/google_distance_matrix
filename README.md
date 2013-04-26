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

    matrix = GoogleDistanceMatrix::Matrix.new

    lat_lng = GoogleDistanceMatrix::Place.new lng: 12, lat: 12
    address = GoogleDistanceMatrix::Place.new address: "My address, Oslo"
    dest_address = GoogleDistanceMatrix::Place.new address: "Home, Oppegaard"

    matrix.origins << lat_lng << address
    matrix.destinations << dest_address

    matrix.configure do |c|
      c.mode = 'driving'
      c.avoid = ['tolls']
    end

    # Returns an array of Google::DistanceMatrix::Route, all having given destination
    matrix.routes_for destination: dest_address

    # Returns Google::DistanceMatrix::Route with given origin and destination
    matrix.route_for origin: lat_lng, destination: dest_address


### Not implemented, yet..

    matrix.shortest_route_by_distance # returns Google::DistanceMatrix::Route with one origin and a destination, together with route data
    matrix.shortest_route_by_duration # returns Google::DistanceMatrix::Route with one origin and a destination, together with route data





## Installation

Add this line to your application's Gemfile:

    gem 'google_distance_matrix'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install google_distance_matrix





## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
