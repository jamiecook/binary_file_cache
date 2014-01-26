require 'rspec'
$: << '../lib'
require 'binary_file_cache'

describe 'a binary file cache' do

  before(:each) do
    @cache_name = 'binary_cache'
    BinaryFileCache::clear(@cache_name)
  end

  after(:each) do BinaryFileCache::clear(@cache_name) end


  it 'should clean up after itself' do
    binary_file_name = BinaryFileCache::get_cache_filename(@cache_name)
    expect(File).not_to exist(binary_file_name)
    ['bin', 'md5'].each { |ext|
      FileUtils.touch(BinaryFileCache::get_cache_filename(@cache_name, ext))
    }
    expect(File).to exist(binary_file_name)
    BinaryFileCache::clear(@cache_name)
    expect(File).not_to exist(binary_file_name)
    expect(File).not_to exist(BinaryFileCache::get_cache_filename(@cache_name, 'md5'))

  end

  it 'should not evaluate the same block twice' do
    count = 0

    value = BinaryFileCache::maybe_evaluate(@cache_name) { count += 1 }
    expect(count).to equal(1)
    expect(value).to equal(1)

    value = BinaryFileCache::maybe_evaluate(@cache_name) { count += 1 }
    expect(count).to equal(1)
    expect(value).to equal(1)

    BinaryFileCache::clear(@cache_name)
    value = BinaryFileCache::maybe_evaluate(@cache_name) { count += 1 }
    expect(count).to equal(2)
    expect(value).to equal(2)
  end

  it 'should notice changes to input files' do
    count = 0
    input_file = File.join(ENV['TEMP'] || ENV['TMPDIR'], 'file.txt')
    File.open(input_file, 'w') { |f| f.puts('old content') }

    value = BinaryFileCache::maybe_evaluate(@cache_name, :input_files => [input_file]) { count += 1 }
    expect(count).to equal(1)
    expect(value).to equal(1)

    value = BinaryFileCache::maybe_evaluate(@cache_name, :input_files => [input_file]) { count += 1 }
    expect(value).to equal(1)
    expect(count).to equal(1)

    File.open(input_file, 'w') { |f| f.puts('new content') }
    value = BinaryFileCache::maybe_evaluate(@cache_name, :input_files => [input_file]) { count += 1 }
    expect(value).to equal(2)
    expect(count).to equal(2)

  end
end