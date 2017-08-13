# frozen_string_literal: true

module Imagesorter
  class FileSystemProcessor
    include R18n::Helpers

    attr_reader :copy_mode

    def initialize(destination:,
                   destination_fmt: '%Y/%m/%d/%<name>s.%<extension>s',
                   copy_mode: :copy,
                   test: false)
      @destination      = destination
      @test             = test
      @copy_mode        = copy_mode
      @destination_fmt  = destination_fmt
    end

    def step_name
      @copy_mode == :move ? 'Moving' : 'Copying'
    end

    def process(file)
      source = file.file.path

      dest = handle_duplicate(source, format_destination(file, full_name: File.basename(source),
                                                               name:      File.basename(source, '.*'),
                                                               extension: File.extname(source).delete('.')))

      return if dest.nil?

      Imagesorter.logger.info "#{step_name} #{source} to #{dest}"

      return if @test

      dest_dir = File.dirname(dest)
      FileUtils.mkdir_p(dest_dir) unless File.directory?(dest_dir)

      if @copy_mode == :move
        FileUtils.mv(source, dest)
      else
        FileUtils.cp(source, dest, preserve: true)
      end
    end

    def format_destination(file, destination_params)
      File.join(@destination, format(l(file.time, @destination_fmt), file.to_h.merge(destination_params)))
    rescue KeyError => e
      Imagesorter.logger.warn e.message

      key = /^key<(.*)> not found$/.match(e.message)[1]

      raise if key.nil?

      destination_params[key.to_sym] = ''
      retry
    end

    def handle_duplicate(source, dest)
      return nil if dest.nil?
      return dest unless File.exist?(dest)

      return nil if FileUtils.identical?(source, dest) # skip if identical

      basename = File.basename(dest, '.*')
      extname  = File.extname(dest)
      dirname  = File.dirname(dest)

      sequence = 1

      handle_duplicate(source, File.join(dirname, "#{basename}_#{sequence}#{extname}"))
    end
  end
end
