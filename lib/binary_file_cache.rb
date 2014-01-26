require "binary_file_cache/version"

module BinaryFileCache
  # Your code goes here...
  def cache_with_file_invalidation(name, input_files, &blk)
    binary_filename = get_cache_filename(name)
    if cache_is_invalid?(binary_filename, input_files)
      cache_block_evaluation(binary_filename, input_files, &blk)
    else
      read_data_from_binary(binary_filename)
      
    end
  end

  def cache_block_evaluation(binary_filename, input_files, &blk)
    cached_data = blk.call
    save_data_to_binary(binary_filename, cached_data)
    save_md5sums(get_cache_md5sums(binary_filename), input_files)
    cached_data
  end

  def save_md5sums(md5_filename, input_files)
    File.open(md5_filename, 'w+') { |output_file|
      output_file.puts(input_files.map { |file|
        [file, Digest::MD5.file(file).hexdigest]
      }).join("\n")
    }
  end

  def get_cache_filename(name)
    File.join(ENV['TEMP'], name + '.bin')
  end
  
  def get_cache_md5sums(binary_filename)
    binary_filename.gsub(/bin$/, 'md5sums')
  end

  def cache_is_invalid?(binary_filename, input_files)
    !File.exists?(binary_filename) && input_files_changed?(input_files)
  end

  def save_data_to_binary(filename, data)
    File.open(filename, 'wb')    { |f| f.print(Marshal::dump(data)) }
  end

  def read_data_from_binary(filename)
    File.open(filename, 'rb') { |file| Marshal.load(file) }
  end

  def clear(binary_filename)
    FileUtils.rm_rf(binary_filename)
  end
end
