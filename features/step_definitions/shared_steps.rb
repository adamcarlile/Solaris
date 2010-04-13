Given /^that I am logged in as a CMS user$/ do
  visit login_path
  fill_in 'E-mail address', :with => "youremail@example.com"
  fill_in 'Password', :with => 'password'
  click_button 'Login'
end

Given %r(^that I am a(?:n)? (.+) user on (.+)$) do |role, page_name|
  Given "that I am logged in as a #{role} user"
  Given "I am on #{page_name}"
  Then "I should be on #{page_name}"
end

Then /^I should see the flash (notice|error) "([^\"]*)"$/ do |type, text|
  within("div#flash.#{type}") do |flash|
    flash.should contain(text)
  end
end

Then /^I should see the tag "([^\"]*)" containing "([^\"]*)"$/ do |tag, text|
  within(tag) do |t|
    t.should contain(text)
  end
end

Then /^I should see an element matching "([^\"]*)" containing "([^\"]*)"$/ do |selector, text|
  within(selector) do |t|
    t.should contain(text)
  end
end

When /^I click "([^\"]*)" within "([^\"]*)"$/ do |link, selector|
  within(selector) do |t|
    click_link(link)
  end
end
