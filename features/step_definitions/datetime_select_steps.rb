When /^(?:|I )select "([^\"]*)" as the "([^\"]*)" time$/ do |time, selector|
  select_time(selector, :with => time)
end

When /^(?:|I )select "([^\"]*)" as the "([^\"]*)" date$/ do |date, selector|
  select_date(selector, :with => date)
end

When /^(?:|I )select "([^\"]*)" as the "([^\"]*)" date and time$/ do |datetime, selector|
  select_datetime(selector, :with => datetime)
end