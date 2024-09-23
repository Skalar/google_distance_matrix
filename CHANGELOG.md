## v.0.7.0

* chore: bumped dependency support up to Rails 7.2 (by yenshirak)
* dropped support for Ruby 2.x

## v.0.6.7

* chore: bumped dependency support up to Rails 7.1 (by justisb)

## v.0.6.6

* chore: require net/http in client.rb (#57)

## v.0.6.5

* chore: bumped dependency support up to Rails 7 (by justisb)

## v.0.6.4

* fix: no longer throwing "Wrong number of arguments" when using the cache (by brianlow)

## v.0.6.3

* chore: bumped dependency support up to Rails 6.1 (by mintyfresh)

## v.0.6.2

* chore: bumped dependency support up to Rails 6 (by zackchandler)

## v.0.6.1

* fix: when matrix places were built from hashes, passing hashes to route/s_for doesnt't work (by brauliomartinezlm)
* fix: place comparison was not working with == (by brauliomartinezlm)

## v.0.6.0

* Depend on activemodel & activesupport < 5.3 (by brauliomartinezlm)
* Tested with Ruby 2.5.
* Dropped support for Ruby 2.2 and below.
* Added support for `channel` (by michaelgpearce)

## v.0.5.0

This release contains breaking change where `url` has been renamed to
`sensitive_url`. A `filtered_url` method is added to make it clear that
the URL returned is filtered according to configuration while the other one
will contain sensitive information like key and signature.

The cache key is changed so it no longer uses the URL, but a digest of the URL
as key. You may set `config.cache_key_transform` to a block passing given url
through if you don't want this.

* Fixed an issue where read/write to cache used url with sensitive data and
  and filtered url resulting in cache miss.
* Instrumentation payload `url` renamed `sensitive_url`.
* Instrumentation payload added `filtered_url`.
* Cache key is a digest of the `sensitive_url` so we don't store in cache the
  sensitive parts of the URL.
* Digesting cache key is configurable with `cache_key_transform`. It's a callable
  object expected to take the url and transform it to the key you want.

## v.0.4.0
* When mode is `driving` and `departure_time` is set all `route` objects will contain
  `duration_in_traffic_in_seconds` and `duration_in_traffic_text`.
  You can also query the matrix by `shortest_route_by_duration_in_traffic_to(place)`.
* Added option to encode origins and destinations as polylines to save characters in the URL.
* Filter sensitive GET params when logging the URL we query Google Matrix with.
* departure_time can now be set to 'now'.
* Dropped support for Ruby 2.0.0

## v.0.3.0
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
