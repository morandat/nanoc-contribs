# Keys
# ai_layout: default layout
# ai_sort_key:
# ai_title:
# ai_extension: restrict to some extensions
# ai_exclude: invert extension filter
# ai_force_title

include Nanoc::Helpers::LinkTo
include Nanoc::Helpers::Rendering
#include Nanoc::Helpers::TagReplacer

module Nanoc::Helpers
    module AutoIndex
        def render_index(ids, opts)
            title = opts.key?(:ai_title) ? opts[:ai_title].to_s : item_name(@item)
            if ids.is_a? Array and ids.length > 0
                indexes = Array.new
                ids.each {|x| indexes.concat Nanoc::Helpers::AutoIndex::find_children(x, opts)}
            else
                indexes = Nanoc::Helpers::AutoIndex::find_children(@item, opts)
            end
            render opts[:ai_layout], title: title, items: indexes
        end

        def find_children(item, opts)
            sort_key = opts.key?(:ai_sort_key) ? opts[:ai_sort_key].to_sym : nil
            ext = opts.key?(:ai_extension) ? Regexp.new(opts[:ai_extension]) : nil
            exclude = opts[:ai_exclude]
            has_title = opts[:ai_force_title]
            lst = item.children
            lst = lst.select{|i| !(i[:ignored] || i[:ai_ignored] || i[:ai_ignore])}
            lst = lst.select{|i| exclude ^ ext.match(i[:extension])} if ext != nil
            lst = lst.select{|i| !has_title || i[:title] != nil}
            lst = lst.sort do |a, b|
              begin
                aa = a[sort_key] || 1000
                bb = b[sort_key] || 1000
                aa <=> bb
              rescue
                0
              end
            end if sort_key != nil
            lst
        end

        def item_name(item)
            return item[:title] if item[:title]
            return File.basename item.path  if item.binary?
            return File.basename item.identifier
        end

        def href(item)
            relative_path_to(item)
        end
    end
end

include Nanoc::Helpers::AutoIndex
module Nanoc::Filters

    AUTO_INDEX_LAYOUT = "ai_default"

    class AutoIndex < Nanoc::Filter

    identifier :autoindex
    type text: :text

        def run(content, params={})
            opts = {
                :ai_layout => AUTO_INDEX_LAYOUT,
                :ai_sort_key => :identifier
            }.merge(params).merge(@item.attributes)

            Nanoc::Helpers::AutoIndex.instance_exec @item, opts, &method(:render_index)
        end
    end
end
