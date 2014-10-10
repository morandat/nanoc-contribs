# encoding: utf-8

module Nanoc::DataSources

  class StaticMetaData < Nanoc::DataSource

    identifier :static_metadata

    def items
      # Get prefix
      prefix = config[:prefix] || 'static'

      # Convert filenames to items
      all_files_in(prefix).map do |filename|
                next if is_metadatafile(filename)
        attributes = load_metadata(filename).merge({
          :extension => File.extname(filename)[1..-1],
          :filename  => filename,
                })
        attributes[:is_hidden] = true unless config[:hide_items] == false
        identifier = filename[(prefix.length + 1)..-1] + '/'
        mtime      = File.mtime(filename)
        checksum   = Pathname.new(filename).checksum

        Nanoc::Item.new(
          filename,
          attributes,
          identifier,
          :binary => attributes.fetch(:binary, true), :mtime => mtime, :checksum => checksum
        )
      end.compact
    end

  protected

        def is_metadatafile(filename)
            pos = filename =~ /\.yaml/ and File.exists?(filename[0..pos - 1])
        end

        def load_metadata(filename)
            metadata_filename = filename + ".yaml"
            if File.exists? metadata_filename then
                YAML.load_file(metadata_filename)
            else
                {}
            end
        end

    def all_files_in(dir_name)
      Nanoc::Extra::FilesystemTools.all_files_in(dir_name)
    end
  end
end
