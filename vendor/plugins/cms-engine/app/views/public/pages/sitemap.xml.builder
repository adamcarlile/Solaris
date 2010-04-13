def xml.add_url(theurl, lastmod = nil)
  url do
    loc theurl
    lastmod lastmod.to_time.strftime('%Y-%m-%d') if lastmod
  end
end

xml.instruct!
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  
  Page.published.select(&:visitable?).each do |page|
    xml.add_url url_for_page(page)
  end

end
