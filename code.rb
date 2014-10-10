module Nanoc::Filters
    class Code < Nanoc::Filter
        Nanoc::Filter.register '::Nanoc::Filters::Code',         :code

        LANG_EXT = { "rb" => :ruby }

        def attr(key, item, default = nil)
            while item != nil
                return item[key] if item.attributes.key?(key)
                item = item.parent
            end
            default
        end

        begin
            require 'htmlentities'

            ESCAPER = HTMLEntities.new

            def escape(str)
                ESCAPER.encode(str)
            end
        rescue LoadError
            def escape(str)
                str.gsub(/[<>&"]/, '<' => '&lt;', '>' => '&gt;', '&' => "&amp;" , "'" => "&apos;", '"' => "&quot;")
            end
        end

        def run(content, params={})
            opts = params.merge({
                :expandtab => attr(:expandtab, @item),
                :escape => attr(:escape, @item, '%%'),
                :language => attr(:language, @item,
                        LANG_EXT.fetch(@item[:extension], @item[:extension]).to_sym)})

            content = content.gsub(/\t/, ' ' * opts[:expandtab]) if opts[:expandtab]
            i = false
            content = content.split(opts[:escape]).map { |s|
                i = !i
                s = escape(s) if i
                s
            }.join('')

            header = "<h1><a href='../#{File.basename(@item[:filename])}'>#{@item[:title] ? @item[:title] : File.basename(@item[:filename])}</a></h1>"
            header << "<pre><code class='language-#{opts[:language].to_s}'>#{content}</code></pre>"
        end
    end
end
