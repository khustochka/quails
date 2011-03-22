Then /^I should see (\d+) observation rows?$/ do |num|
  all('.obs-row').size.should == num.to_i
end