# frozen_string_literal: true

require 'optparse'

module Imagesorter
  module OptionParser
    DEFAULT_OPTIONS = {
      silent: false,
      test: false,
      recursive: false,
      copy_mode: :copy,
      threads: 1,
      locale: 'en-us',
      extensions: %w[JPG JPEG MP4 MOV PNG CR2],
      destination_format: '%Y/%m/%d/%{full_name}' # rubocop:disable Style/FormatStringToken
    }.freeze

    def self.parse(argv) # rubocop:disable  Metrics/MethodLength, Metrics/AbcSize
      options = OpenStruct.new(DEFAULT_OPTIONS)

      # rubocop:disable Metrics/BlockLength
      parser = ::OptionParser.new do |opts|
        opts.banner = 'Usage: imagesorter [options]'

        opts.on('-s', '--source SOURCE_DIR', 'Source directory') do |source|
          options.source = source
        end

        opts.on('-d', '--dest DESTINATION_DIR', 'Destination directory (will be created if it does not exist)') do |dest|
          options.dest = dest
        end

        opts.on('-t', '--threads THREADS', "Number of threads to run the processing in (default is #{options.threads})") do |threads|
          options.threads = threads
        end

        opts.on('-m', '--move', 'Move rather than copy') do
          options.copy_mode = :move
        end

        opts.on('-e', '--extensions EXTENSIONS', Array, "What extensions to include (default is #{options.extensions.join(',')})") do |extensions|
          options.extensions = extensions
        end

        opts.on('-r', '--recursive', "Iterate source recursively (default is #{options.recursive})") do |recursive|
          options.recursive = recursive
        end

        opts.on('-l', '--logfile LOGFILE', 'Write message to given logfile. Default output is STDOUT') do |logfile|
          options.logfile = logfile
        end

        opts.on('--locale LOCALE', "Locale to use (default is #{options.locale})") do |locale|
          options.locale = locale
        end

        opts.on('--destination-format DESTINATION_FORMAT', "Destination format (default is #{options.destination_format})") do |destination_format|
          options.destination_format = destination_format
        end

        opts.on('--[no-]silent', 'Run silently') do |silent|
          options.silent = silent
        end

        opts.on('--[no-]test', 'Do a test-run without touching any files') do |test|
          options.test = test
        end

        opts.separator ''
        opts.separator 'Common options:'
        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end

        opts.on('--verbose', 'Increase log message verbosity') do |verbose|
          options.verbose = verbose
        end

        # Another typical switch to print the version.
        opts.on_tail('-v', '--version', 'Show version') do
          puts Imagesorter::Gem.version
          exit
        end
      end
      # rubocop:enable Metrics/BlockLength

      parser.parse!(argv)

      validate_mandatory_options!(options)

      options
    rescue ::OptionParser::InvalidOption, ::OptionParser::MissingArgument => e
      puts e.to_s
      puts parser
      exit
    end

    def self.validate_mandatory_options!(options)
      mandatory = %i[source dest]
      missing = mandatory.select { |param| options[param].nil? }
      return if missing.empty?

      raise ::OptionParser::MissingArgument, missing.join(', ')
    end
  end
end
