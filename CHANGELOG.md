## v.0.3.0 (unreleased)
This release includes one breaking change, the removal of sensor parameter.
This parameter is no longer used - see:
https://developers.google.com/maps/documentation/distance-matrix/intro#Sensor

* Remove sensor attribute. (by rpocklin)
* Added "transit_routing_preference" and "traffic_model" attributes to request. (by rpocklin)
* Added "ferries", "indoor" as valid avoid value. (by rpocklin)

## v.0.2.1
* Made https be default (by almnes)

## v.0.2.0
* Dropped support for Ruby 1.9.X
* Added new configuration options: google_api_key,
  transit, transit_mode, arrival_time and departure_time. (by lsanwick)


## v.0.1.3
* Be optimistic in regards to ActiveSupport and ActiveModel version we support.

## v.0.1.2
* Allowed for ActiveSupport and ActiveModel up 4.2.x.
* Fixed 'ArgumentError: wrong number of arguments (2 for 0..1)' when gem tried to log event to
  log event via log subscriber with Rails 4.2.

## v.0.1.1
* Allowed for ActiveSupport and ActiveModel up until 4.2. (by mask8)

## v.0.1.0
* Allowed for ActiveSupport and ActiveModel 4.1.
* Removed Route#distance_value and Route#duration_value. Use distance_in_meters and duration_in_seconds.
* Add language parameter to matrix configuration (by Iuri Fernandes)


## v.0.0.3
* Bumped version of google_business_api_url_signer to get Ruby 2 support.

## v.0.0.2

* Renamed RequestError to ServerError.
* Added ability to cache API responses using an ActiveSupport::Cache::Store. Simply using URL as cache key.
* Explicit instrumentation and logging how many elements requested from the API.


## v.0.0.1

* First release.
