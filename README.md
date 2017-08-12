# imagesorter

[![Build Status](https://travis-ci.org/anakinj/imagesorter.svg?branch=master)](https://travis-ci.org/anakinj/imagesorter)
[![Code Climate](https://codeclimate.com/github/anakinj/imagesorter/badges/gpa.svg)](https://codeclimate.com/github/anakinj/imagesorter)
[![Gem Version](https://badge.fury.io/rb/imagesorter.svg)](https://badge.fury.io/rb/imagesorter)

A command line tool that sorts your photos and videos (actually any files you tell it to sort) based on date it was created or EXIF information from the picture. The tool can do it's magic in parallel.

The tool was inspired by [https://github.com/andrewning/sortphotos](https://github.com/andrewning/sortphotos), but I wanted the process to be done in multiple threads to minimize the wait time and my pearl skills are a little rusty.


## Installation

```gem install imagesorter``` and you're good to go.

Currently the tool requires Ruby 2.1 or newer.

## Usage

```imagesorter --help``` gives you all the details

### Destination format

The destination format is used to configure the template where into the destination the files will be copied, the template will be populated with metadata extracted from the source file.

The source file metadata is referred to with the ```%{key}``` notation. Also directives used for [formatting timestamps](https://ruby-doc.org/stdlib-2.1.1/libdoc/date/rdoc/Date.html#method-i-strftime) are available.

Keys that are not found are replaced with a empty string.

```imagesorter -s . -d /my/dest --destination-format "%{exif.make} %{exif.model}/%Y/%m/%d/%{full_name}```

#### File metadata
| Key | Description |
| --- | --- |
| name      | Name of the source file |
| extension | Extension of the source file |
| full_name | Alias for name+extension |
| exif.*    | Data extracted from the image EXIF data |

#### Duplicate handling

The tool checks for duplicates and identical files are ignored. On conflicting filenames the file to be copied gets an additional tag in the filename, no existing files will be touched.
