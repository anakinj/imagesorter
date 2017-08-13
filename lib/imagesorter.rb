# frozen_string_literal: true

require 'logger'
require 'fileutils'
require 'ostruct'
require 'r18n-core'
require 'exifr/jpeg'
require 'json'

R18n.set('en')

require 'imagesorter/gem'
require 'imagesorter/sortable_file'
require 'imagesorter/categorizers/chained_categorizer'
require 'imagesorter/categorizers/file_exif_categorizer'
require 'imagesorter/categorizers/file_stat_categorizer'
require 'imagesorter/file_system_processor'
require 'imagesorter/file_batch_processor'
