module Includes

	def includes(item)
		final_includes = []
		final_includes += @config[:global_includes]
		current_item = item
		while current_item !=  nil do
			final_includes += current_item[:includes] if current_item[:includes] != nil
			current_item = current_item.parent
		end 
		s = ''
		final_includes.each{ |incl| 
			s << render(incl)
		}
		return s
	end
end
