# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2017-08-11

### Added
 - --verbose flag for outputting the available metadata for files
 - Handle missing keys used in destination format

## [1.1.0] - 2017-08-11

### Added
 - Added MOV to the default extensions
 - Duplicate handling: Skip if identical or add sequence number if content differs

### Changed
 - The timestamp-format parameter has been removed. Everything related to the destination path is now under the destination-format parameter

## [1.0.0] - 2017-08-09
### Added
 - Initial release
