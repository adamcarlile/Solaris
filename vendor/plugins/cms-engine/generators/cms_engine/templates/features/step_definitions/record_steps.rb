Given /^the following (.+) records:$/ do |model_name, table|
  model_name = model_name.gsub(' ', '_')
  model_name.camelize.constantize.destroy_all
  table.hashes.each do |hash|
    Factory(model_name.to_sym, hash)
  end
end

Given /^there are no (.+) records$/ do |model_name|
  model_name.gsub(' ', '_').camelize.constantize.destroy_all
end

Then /^I should have (\d+) (.+)$/ do |count, model_name|
  model_name.singularize.gsub(' ', '_').camelize.constantize.count.should == count.to_i
end
