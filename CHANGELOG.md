# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[Unreleased]: https://github.com/fast-jsonapi/fast_jsonapi/compare/dev...HEAD
[1.6.0]: https://github.com/fast-jsonapi/fast_jsonapi/compare/1.5...1.6.0