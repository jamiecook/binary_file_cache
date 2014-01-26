require "binary_file_cache/version"

module BinaryFileCache
  def self.maybe_evaluate(name, opts = {}, &blk)
    binary_filename = get_cache_filename(name)
    if cache_is_invalid?(name, opts[:input_files])
      clear(name)
      cache_block_evaluation(name, opts[:input_files], &blk)
    else
      read_data_from_binary(binary_filename)
    end
  end

  def self.cache_block_evaluation(cache_name, input_files, &blk)
    cached_data = blk.call
    save_data_to_binary(get_cache_filename(cache_name), cached_data)
    save_md5sums(get_cache_filename(cache_name, 'md5'), input_files)
    cached_data
  end

  def self.save_md5sums(md5_filename, input_files)
    return unless input_files
    File.open(md5_filename, 'w+') { |output_file|
      output_file.puts(calculate_md5sums(input_files).join("\n"))
    }
  end

  def self.calculate_md5sums(input_files)
    input_files.map { |file| Digest::MD5.file(file).hexdigest }
  end

  def self.read_md5sums(md5_filename)
    IO.readlines(md5_filename).map(&:strip)
  end

  def self.get_cache_filename(name, ext = 'bin')
    File.join(ENV['TEMP'] || ENV['TMPDIR'], name + '.' + ext)
  end

  def self.cache_is_invalid?(cache_name, input_files)
    return true unless File.exists?(get_cache_filename(cache_name))
    return input_files && input_files_changed?(cache_name, input_files)
  end

  def self.input_files_changed?(cache_name, input_files)
    prev_md5sums = read_md5sums(get_cache_filename(cache_name, 'md5'))
    calculate_md5sums(input_files).zip(prev_md5sums).any? { |new,old| new != old }
  end

  def self.save_data_to_binary(filename, data)
    File.open(filename, 'wb') { |f| f.print(Marshal::dump(data)) }
  end

  def self.read_data_from_binary(filename)
    File.open(filename, 'rb') { |file| Marshal.load(file) }
  end

  def self.clear(cache_name)
    %w[bin md5].each { |ext| FileUtils.rm_rf(get_cache_filename(cache_name, ext)) }
  end
end
