# frozen_string_literal: true

describe Imagesorter::FileBatchProcessor do
  let(:fixture_dir) { File.join(Imagesorter::Gem.root, 'spec', 'fixtures', 'images') }
  let(:tmp_dir)     { File.join(Imagesorter::Gem.root, 'tmp', SecureRandom.hex) }
  let(:test_dir)    { File.join(tmp_dir, SecureRandom.hex) }

  before do
    FileUtils.mkdir_p(test_dir)
    Dir.foreach(fixture_dir) do |file|
      source = File.join(fixture_dir, file)
      next unless File.file?(source)

      dest = File.join(test_dir, file)
      FileUtils.cp(source, dest)
      FileUtils.touch(dest, mtime: Time.new(2017, 8, 6))
    end
  end

  after do
    begin
      FileUtils.rm_rf(tmp_dir)
    rescue StandardError
      nil
    end
  end

  let(:mtime_categorizer) do
    Imagesorter::Categorizers::ChainedCategorizer.new(Imagesorter::Categorizers::FileExifCategorizer.new,
                                                      Imagesorter::Categorizers::FileStatCategorizer.new(:mtime))
  end

  describe '#collect!' do
    it 'collects the files from the source directories' do
      instance = described_class.new(source: test_dir, categorizer: mtime_categorizer, processor: nil)
      instance.collect!

      expect(instance.files).to be_a(Array)
      expect(instance.files.size).to be > 1
    end

    it 'iterates folders recursively' do
      child_dir = File.join(test_dir, 'child')
      FileUtils.mkdir_p(child_dir)
      FileUtils.mv(File.join(test_dir, 'test1.jpg'), child_dir)

      instance = described_class.new(source: test_dir,
                                     recursive: true,
                                     categorizer: mtime_categorizer, processor: nil)
      instance.collect!

      expect(instance.files).to be_a(Array)
      expect(instance.files.size).to be > 1
    end

    it 'allows filtering by file extension' do
      instance = described_class.new(source: test_dir,
                                     extensions: ['jpeg'],
                                     categorizer: mtime_categorizer, processor: nil)
      instance.collect!

      expect(instance.files).to be_a(Array)
      expect(instance.files.size).to eq 1
    end
  end

  describe '#execute!' do
    it 'iterates all collected files and uses the categorizer to categorize the file' do
      instance = described_class.new(source: test_dir,
                                     categorizer: mtime_categorizer,
                                     processor: nil)
      instance.execute!
      expect(instance.files.first.time).to eq(Time.new(2017, 8, 6))
    end

    it 'iterates all collected files and uses the processor to process the file' do
      instance = described_class.new(source: test_dir,
                                     categorizer: mtime_categorizer,
                                     processor: Imagesorter::FileSystemProcessor.new(destination: tmp_dir))

      instance.execute!

      expect(File.exist?(File.join(tmp_dir, '2017', '08', '06', 'test1.jpg'))).to eq true
    end

    it 'can move files instead of copying' do
      instance = described_class.new(source: test_dir,
                                     categorizer: mtime_categorizer,
                                     processor: Imagesorter::FileSystemProcessor.new(destination: tmp_dir,
                                                                                     copy_mode: :move))

      instance.execute!
      expect(File.exist?(File.join(test_dir, 'test1.jpg'))).to eq false
      expect(File.exist?(File.join(tmp_dir, '2017', '08', '06', 'test1.jpg'))).to eq true
    end

    it 'uses a empty value for the missing keys' do
      instance = described_class.new(source: test_dir,
                                     categorizer: mtime_categorizer,
                                     processor: Imagesorter::FileSystemProcessor.new(destination: tmp_dir,
                                                                                     destination_fmt: '%Y/%m/%d/%<noop>s/%<name>s.%<extension>s'))
      instance.execute!
      expect(File.exist?(File.join(tmp_dir, '2017', '08', '06', 'test1.jpg'))).to eq true
    end

    it 'does not overwrite existing files' do
      instance = described_class.new(source: test_dir,
                                     categorizer: mtime_categorizer,
                                     processor: Imagesorter::FileSystemProcessor.new(destination: tmp_dir,
                                                                                     copy_mode: :move))
      dest = File.join(tmp_dir, '2017', '08', '06')
      FileUtils.mkdir_p(dest)
      FileUtils.cp(File.join(fixture_dir, 'test2.jpg'), File.join(dest, 'test1.jpg'))
      FileUtils.cp(File.join(fixture_dir, 'test2.jpg'), File.join(dest, 'test1_1.jpg'))
      instance.execute!

      expect(File.exist?(File.join(tmp_dir, '2017', '08', '06', 'test1_1_1.jpg'))).to eq true
    end
  end
end
