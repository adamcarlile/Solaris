Given /^the following comments on the page "([^\"]*)":$/ do |slug_path, table|
  page = Page.find_by_slug_path(slug_path)
  table.hashes.each do |hash|
    comment = page.comments.build(hash)
    comment.approved = hash["approved"].to_i
    comment.save
  end
end
