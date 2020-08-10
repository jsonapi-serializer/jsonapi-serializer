# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Remove `ObjectSerializer#serialized_json` (#91)

### Fixed
- Ensure caching correctly incorporates fieldset information into the cache key to prevent incorrect fieldset caching (#90)

## [1.7.2] - 2020-05-18
### Fixed
- Relationship#record_type_for does not assign static record type for polymorphic relationships (#83)

## [1.7.1] - 2020-05-01
### Fixed
- ObjectSerializer#serialized_json accepts arguments for to_json (#80)

## [1.7.0] - 2020-04-29
### Added
- Serializer option support for procs (#32)
- JSON serialization API method is now implementable (#44)

### Changed
- Support for polymorphic `id_method_name` (#17)
- Relationships support for `&:proc` syntax (#58)
- Conditional support for procs (#59)
- Attribute support for procs (#67)
- Refactor caching support (#52)
- `is_collection?` is safer for objects (#18)

### Removed
- `serialized_json` is now deprecated (#44)

## [1.6.0] - 2019-11-04
### Added
- Allow relationship links to be delcared as a method ([#2](https://github.com/fast-jsonapi/fast_jsonapi/pull/2))
- Test against Ruby 2.6 ([#1](https://github.com/fast-jsonapi/fast_jsonapi/pull/1))
- Include `data` key when lazy-loaded relationships are included  ([#10](https://github.com/fast-jsonapi/fast_jsonapi/pull/10))
- Conditional links [#15](https://github.com/fast-jsonapi/fast_jsonapi/pull/15)
- Include params on set_id block [#16](https://github.com/fast-jsonapi/fast_jsonapi/pull/16)
### Changed
- Optimize SerializationCore.get_included_records calculates remaining_items only once ([#4](https://github.com/fast-jsonapi/fast_jsonapi/pull/4))
- Optimize SerializtionCore.parse_include_item by mapping in place ([#5](https://github.com/fast-jsonapi/fast_jsonapi/pull/5))
- Define ObjectSerializer.set_key_transform mapping as a constant ([#7](https://github.com/fast-jsonapi/fast_jsonapi/pull/7))
- Optimize SerializtionCore.remaining_items by taking from original array ([#9](https://github.com/fast-jsonapi/fast_jsonapi/pull/9))
- Optimize ObjectSerializer.deep_symbolize by using each_with_object instead of Hash[map] ([#6](https://github.com/fast-jsonapi/fast_jsonapi/pull/6))
