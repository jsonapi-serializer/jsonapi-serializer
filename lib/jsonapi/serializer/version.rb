module JSONAPI
  module Serializer
    # ART19 maintains a fork with patches applied on top of the upstream gem.
    # We publish our fork with a revision number appended to the upstream version.
    ART19_REVISION = '1'.freeze
    VERSION = "2.2.0.#{ART19_REVISION}".freeze
  end
end
