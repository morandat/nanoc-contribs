# encoding: UTF-8 

module Nanoc::Filters
    class TagReplacer < Nanoc::Filter

    identifier :tagreplacer
    type :text

        ID=%r{(((?<id>[^ \t\r\n\f'"/:][^ \t\r\n\f:]*))|(((?<p>[/'"])(?<escaped>((?!\k<p>)[^\\]|\\.)*)\k<p>)))}
        PARAM_TAG = %r{(((?<key>\w+):(#{ID}))|(#{ID}))}
        TAG_REPLACER_TAG = %r{\(:\s*(?<tag>\w+)\s*(?<val>((#{PARAM_TAG})\s*)*):\)}

        include Nanoc::Helpers::Rendering
        include Nanoc::Filters
        @@filters = Hash.new

        def run(content, params={})
            filters = @@filters
            opts = params.merge(@item.attributes)

            ## For each tag
            content = content.gsub(TAG_REPLACER_TAG) do |match|
                m = match.match TAG_REPLACER_TAG
                tag = m[:tag].to_sym
                if filters.key?(tag) and (!opts.key?(:filters) or opts[:filters].include?(tag))
                    lidents = Array.new
                    lopts = Hash.new
                    extract_tag_param m[:val], lopts, lidents
                    procedure, opts = filters[tag]
                    begin
                        instance_exec(lidents,
                                      opts.merge(params).
                                        merge(@item.attributes).
                                        merge(lopts),
                                      &procedure)
                    rescue ReplacementException => e
                        warn "In #{@item.identifier}: #{e.message}"
                        warn ">> #{match}"
                        next e.replacement == nil ? match : e.replacement
                    end
                else
                    warn "In #{@item.identifier}: No such tag #{tag}" unless filters.key? tag
                    match
                end
            end
            content
        end

        def extract_tag_param(tag_val, lopts, lidents)
          tag_val.scan PARAM_TAG do |x|
            if x[4].nil? and x[6].nil?
              lopts[x[0].to_sym] = (x[1] or x[3].gsub(/\\(.)/, "\\1"))
            else
              lidents << (x[4] or x[6].gsub(/\\(.)/, "\\1"))
            end
          end
        end

        def self.register_tag(tag, default_opts={}, &block)
            @@filters[tag.to_sym] = [ block, default_opts ]
        end

        class ReplacementException < RuntimeError
            attr_reader :replacement
            def initialize msg, replacement = ""
                super msg
                @replacement = replacement
            end
        end
    end
end

module Nanoc::Helpers
    def self.replace_tag tag, default_opts={}, &block
        Nanoc::Filters::TagReplacer.register_tag tag, default_opts, &block unless default_opts[:disabled]
    end

    def self.skip_replacement msg, replacement=""
        raise Nanoc::Filters::TagReplacer::ReplacementException.new msg, replacement
    end
end
