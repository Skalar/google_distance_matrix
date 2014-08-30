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
