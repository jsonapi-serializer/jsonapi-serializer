# JSON Serialization Support

Support for JSON serialization is no longer provided as part of the API of
`fast_jsonapi`. This decision (see #12) is based on the idea that developers
know better what library for JSON serialization works best for their project.

To bring back the old functionality, define the `to_json` or `serialized_json`
methods with the relevant JSON library call. Here's an example on how to get
it working with the popular `oj` gem:

```ruby
require 'oj'
require 'fast_jsonapi'

class BaseSerializer
  include JSONAPI::Serializer

  def to_json
    Oj.dump(serializable_hash)
  end
  alias_method :serialized_json, :to_json
end

class MovieSerializer < BaseSerializer
  # ...
end
```
