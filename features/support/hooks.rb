After('@admin') do
  if page.driver.respond_to?(:basic_authorize)
    page.driver.basic_authorize('','')
  end
end