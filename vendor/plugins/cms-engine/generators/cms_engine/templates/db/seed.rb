[User,Page,Image,FileUpload].each do |klass|
  klass.destroy_all
end

%w(cms_user writer editor admin).each {|name| Role.find_or_create_by_name(name)}

user = User.new({
  :firstname => 'Your',
  :lastname => 'Name',
  :email => "youremail@example.com",
  :password => 'password',
  :password_confirmation => 'password',
})
user.save!
user.activate!
user.roles = Role.all
 
global_nav = Factory(:top_level_folder)
Factory(:top_level_folder, :title => 'Footer nav')
Factory(:top_level_folder, :title => 'Other pages')

# Homepage
Factory(:published_page, :type => 'Homepage', :position => 1, :parent_id => global_nav.id, :title => 'Welcome to our site', :slug_path => 'home', :nav_title => 'Home')

# Folder with basic sub pages
about_us = Factory(:folder, :position => 2, :state => 'published', :visible => true, :parent_id => global_nav.id, :title => "About us")
Factory(:published_page, :parent_id => about_us.id, :title => 'Services', :tag_list => '"Tag 1" tag2 tag3')
Factory(:published_page, :parent_id => about_us.id, :title => 'Company')


news = Factory(:published_page, :type => "NewsIndex", :position => 2, :parent_id => global_nav.id, :title => "News")
10.times do |n|
  Factory(:published_page, :type => "NewsItem", :created_at => (n+2).weeks.ago, :publish_from => (n+2).weeks.ago, :position => (n+1), :parent_id => news.id, :title => "Article #{n+1}")
end

faq_index = Factory(:published_page, :type => "FaqIndex", :position => 3, :parent_id => global_nav.id, :title => "FAQ", :intro => "Your questions answered.")
5.times do |n|
  Factory(:published_page, :type => "Question", :parent_id => faq_index.id, :title => "Question #{n+1}?")
end

Factory(:published_page, :type => "ContactForm", :position => 4, :parent_id => global_nav.id, :title => 'Contact us')

Page.all.each &:save