module Nanoc::Filters
    class SVG2PNGFilter < Nanoc::Filter
        identifier :svg2png
        type :binary

        def run(filename, params={})
            args = ["rsvg-convert"]
            args << "-w" << @item[:width].to_s if @item[:width]
            args << "-h" << @item[:height].to_s if @item[:height]
            args << "-o" << output_filename << filename
            system(*args)
        end
    end
end
