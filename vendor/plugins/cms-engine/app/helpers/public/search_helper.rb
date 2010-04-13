module Public::SearchHelper
  
  def url_for_search_result(result)
    if result.kind_of?(Page)
      send("url_for_page", result)
    else
      send("url_for_#{result.class.to_s.underscore}", result)
    end
  end
  
end

