include Nanoc::Helpers::Rendering

module Nanoc::Filters
    class CSVRenderer < Nanoc::Filter
        identifier :csvbinary
        type :binary
        
        require 'csv'

        def run(content, params={})
          attrs = { :col_sep => ';', :csv_layout => 'csv' }.merge @item.attributes

          File.open output_filename, "w" do |res|
              CSV.foreach(content, :col_sep => ';') do |row|
                  res.write render(attrs[:csv_layout], :row => row)
              end
          end
        end
    end

    class CSVRenderer < Nanoc::Filter
        identifier :csv
        type :text
        
        require 'csv'

        def run(content, params={})
          attrs = { :col_sep => ';', :headers => false,
              :csv_layout => 'csv', :csv_headers => 'csvheaders', :csv_footer => 'csvfooter',
              :csv_id => 'csvtable', :csv_classes => 'table table-striped table-hover tablesorter'
              }.merge @item.attributes

          res = ''
          CSV.parse(content, :col_sep => attrs[:col_sep], :headers => attrs[:headers]) do |row|
              if res == '' && attrs[:csv_headers] then
                  res << render(attrs[:csv_headers], :row => row)
              else
                  res << render(attrs[:csv_layout], :row => row)
              end
          end
          "#{"<h2>#{attrs[:message]}</h2>" if attrs[:message]}<table id='#{attrs[:csv_id]}' class='#{attrs[:csv_classes]}'>#{res}</table>#{render(attrs[:csv_footer]) if attrs[:csv_footer]}"
        end
    end
end
