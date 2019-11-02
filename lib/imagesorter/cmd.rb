# frozen_string_literal: true

require 'imagesorter/option_parser'
require 'imagesorter'
require 'progressbar'

module Imagesorter
  class Cmd
    attr_reader :progressbar

    def initialize
      @options = Imagesorter::OptionParser.parse(ARGV)
    end

    def run
      print_options

      setup_logger
      setup_locale

      Imagesorter::FileBatchProcessor.new(batch_options).execute!

      finalize

      puts 'DONE'
      exit 0
    rescue Interrupt
      puts 'FAIL: INTERRUPTED'
      exit 1
    rescue StandardError => e
      puts e
      puts e.backtrace
      exit 2
    end

    private

    def setup_logger
      Imagesorter.logger = Logger.new(@options.logfile) if @options.logfile

      Imagesorter.logger.level = resolve_log_level

      Imagesorter.logger.formatter = proc do |severity, datetime, _progname, msg|
        date_format = datetime.strftime('%Y-%m-%d %H:%M:%S')
        if @options.test
          "[#{date_format}] [#{severity}] TEST - #{msg}\n"
        else
          "[#{date_format}] [#{severity}] #{msg}\n"
        end
      end
    end

    def resolve_log_level
      return Logger::DEBUG if @options.verbose == true

      return Logger::FATAL if @options.silent == true && !@options.logfile

      Logger::INFO
    end

    def setup_locale
      R18n.locale(@options.locale)
      R18n.set(@options.locale)
    end

    def batch_options
      options = {
        source: @options.source,
        recursive: @options.recursive,
        extensions: @options.extensions,
        processor: Imagesorter::FileSystemProcessor.new(destination: @options.dest,
                                                        destination_fmt: @options.destination_format,
                                                        copy_mode: @options.copy_mode,
                                                        test: @options.test)
      }

      options[:progress_proc] = proc { |progress_options| progress(progress_options) } if progressbar_enabled?

      options
    end

    def print_options
      puts "Source:      #{@options.source}"
      puts "Destination: #{@options.dest}"
      puts "Threads:     #{@options.threads}"
    end

    def finalize
      @progressbar&.finish
    end

    def progressbar_enabled?
      @options.silent == false && !@options.logfile.nil?
    end

    def progress(progress_options)
      @progressbar ||= ProgressBar.create(format: '%a %e %P% %t %c of %C',
                                          autofinish: false)
      @progressbar.title = progress_options[:step]
      @progressbar.total = progress_options[:total_steps]
      @progressbar.increment
    end
  end
end
