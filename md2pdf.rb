require "kramdown"

module Nanoc::Filters
    class MD2PDFConverter < Nanoc::Filter
        identifier :md2pdf
        type :text => :binary

        def run(content, params={})
          File.write(output_filename, ::Kramdown::Document.new(content).to_pdf)
        end
    end
end
