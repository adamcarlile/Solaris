Factory.sequence :email do |n|
  "person#{n}@example.com"
end
Factory.sequence :token do |n|
  "k3cFzLIQnZ4MHRmJvJzg#{n}"
end

Factory.define :user do |u|
  u.email { Factory.next(:email) }
  u.password "123456"
  u.password_confirmation {|u| u.password}
  u.single_access_token { Factory.next(:token) }
end

Factory.define :top_level_folder , :class => Folder do |p|
  p.title "Global Nav"
  p.state 'published'
  p.locked true
  p.position 1
end

Factory.define :folder , :class => Folder do |p|
  p.title "Folder"
end

Factory.define :page, :class => BasicPage do |p|
  p.title "About Us"
  p.position 1
  p.association :parent, :factory => :top_level_folder
  p.intro Faker::Lorem.sentence(10)
  p.body "<p>" + Faker::Lorem.paragraphs(2).join("</p>\n<p>") + "</p>"
end

Factory.define :published_page, :parent => :page do |p|
  p.state 'published'
  p.visible true
end


Factory.define :file_upload do |f|
  f.title "File Title"
  f.file { File.open( File.join(CmsEngine::ROOT,'spec/fixtures/files/test.xls')) }
end

Factory.define :image do |f|
  f.file { File.open( File.join(CmsEngine::ROOT,'spec/fixtures/images/mm.jpg')) }
end
