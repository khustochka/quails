desc 'Test benchmark'
task :test_bm => :environment do
  require 'benchmark'
  require 'test/unit'

  sp = Species.find_by_code!('lancol')
  obs = Factory.create(:observation, :species => sp, :observ_date => "2008-06-20")
  obs.images << Factory.create(:image, :code => 'Picture of the Shrike')

  500.times { Factory.create(:observation, :species => sp) }

  n = 100
  Benchmark.bm do |x|
    x.report('1st') { sp.observations.map(&:images).flatten }
    x.report('2nd') { sp.observations.map(&:images).flatten }
  end
end