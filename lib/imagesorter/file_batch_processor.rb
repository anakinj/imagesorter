# frozen_string_literal: true

module Imagesorter
  class FileBatchProcessor
    attr_reader :files

    def initialize(source:,
                   processor:,
                   categorizer: nil,
                   progress_proc: nil,
                   threads: 1,
                   extensions: nil,
                   recursive: false)
      @dir           = source
      @categorizer   = categorizer || Categorizers::ChainedCategorizer.new(Categorizers::FileExifCategorizer.new,
                                                                           Categorizers::FileStatCategorizer.new(:ctime))
      @processor     = processor
      @progress_proc = progress_proc
      @queue         = Queue.new
      @files         = []
      @threads       = threads
      @recursive     = recursive
      @extensions    = Array(extensions).map(&:upcase)
      @total_steps   = nil

      @skipped_files = 0
    end

    def execute!
      collect!

      @total_steps = @skipped_files + @files.size * 3

      process!

      if @threads > 1
        start_queue_workers
      else
        work_on_queue
      end
    end

    def collect!
      @files = []

      collect_files_from_dir(@dir)
    end

    def collect_files_from_dir(dir)
      Dir.foreach(dir) do |file|
        collect_file_from_dir(dir, file)
      end
    end

    def collect_file_from_dir(dir, file)
      return if file =~ /^\.\.?$/
      full_path = File.join(dir, file)

      if File.directory?(full_path)
        collect_files_from_dir(full_path) if @recursive
        return
      end

      if include_file?(full_path)
        @files << SortableFile.new(full_path)
      else
        @skipped_files += 1
      end

      increment('Collecting files')
    end

    def include_file?(file)
      File.file?(file) &&
        (@extensions.empty? || @extensions.include?(File.extname(file).delete('.').upcase))
    end

    def process!
      @files.each do |file|
        queue_categorizing(file)
      end
    end

    def queue_categorizing(file)
      queue_job do
        file.process!(@categorizer)

        Imagesorter.logger.debug "#{file.file.path} metadata: #{JSON.pretty_generate(file.to_h)}"

        increment(@categorizer.step_name)
        queue_proceesing(file)
      end
    end

    def queue_proceesing(file)
      return if @processor.nil?
      queue_job do
        file.process!(@processor)
        increment(@processor.step_name)
      end
    end

    def increment(step)
      return if @progress_proc.nil?
      @progress_proc.call(step: step.ljust(14, ' '),
                          total_steps: @total_steps)
    end

    def queue_job(&block)
      @queue.push(block)
    end

    def work_on_queue
      until @queue.empty?
        job = @queue.shift
        job.call
      end
    end

    def start_queue_workers
      @threads = Array.new(@threads) do
        Thread.new do
          work_on_queue
        end
      end

      @threads.each(&:join)
    end
  end
end
