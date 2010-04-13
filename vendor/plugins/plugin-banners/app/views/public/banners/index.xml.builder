xml.instruct! :xml, :version=>"1.0"
xml.promotions{
  for banner in @collection
    xml.item do 
      xml.title(banner.name)
      xml.url(banner.url)
      xml.image(banner.banner.url(:banner))
    end
  end
}