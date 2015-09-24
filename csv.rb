include Nanoc::Helpers::Rendering

module Nanoc::Filters
    class CSVRenderer < Nanoc::Filter
        identifier :csvbinary
        type :binary
        
        require 'csv'

        def run(content, params={})
          attrs = { :col_sep => ';', :cvs_layout => 'csv' }.merge @item.attributes

          File.open output_filename, "w" do |res|
              CSV.foreach(content, :col_sep => ';') do |row|
                  res.write render(attrs[:cvs_layout], :row => row)
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
              :cvs_layout => 'csv', :cvs_headers => 'csvheaders'
              }.merge @item.attributes

          res = ''
          CSV.parse(content, :col_sep => attrs[:col_sep], :headers => attrs[:headers]) do |row|
              if res == '' && attrs[:cvs_headers] then
                  res << render(attrs[:cvs_headers], :row => row)
              else
                  res << render(attrs[:cvs_layout], :row => row)
              end
          end
          "#{"<h2>#{attrs[:message]}</h2>" if attrs[:message]}<table class='table table-striped table-hover'>#{res}</table>"
        end
    end
end
