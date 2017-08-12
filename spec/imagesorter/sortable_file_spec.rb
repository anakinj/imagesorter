# frozen_string_literal: true

describe Imagesorter::SortableFile do
  it 'takes a path in the constructor' do
    test_file = File.join(Imagesorter::Gem.root, 'spec', 'fixtures', 'images', 'test1.jpg')
    expect(described_class.new(test_file)).to be_a(described_class)
  end
  it 'raises if the files does not exist' do
    expect { described_class.new(File.join('Im', 'not', 'here')) }.to raise_error(Errno::ENOENT)
  end
end
