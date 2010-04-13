When /^I (.+) the (\d+)(?:st|nd|rd|th) item in the table$/ do |action, pos|
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link action.capitalize
  end
end

Then /^I should see the following rows in the table:$/ do |table|
  table.rows.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      response.should have_selector("table > tr:nth-child(#{i+2}) > td:nth-child(#{j+1})") { |td|
        td.inner_text.to_s.should == cell.to_s
      }
    end
  end
end

Then /^I should see "(.+)" in the (\d+)(?:st|nd|rd|th) row of the table$/ do |text, pos|
  within("table > tr:nth-child(#{pos.to_i+1})") do |row|
    row.should contain(text)
  end
end
