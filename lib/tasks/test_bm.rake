desc 'Test benchmark'
task :test_bm => :environment do
  require 'benchmark'
  require 'test/unit'

  n = 100
  Benchmark.bm do |x|
    x.report('1st') { n.times {} }
    x.report('2nd') { n.times {} }
  end
end

desc 'show species with more than a year between observations'
task :more_than_year => :environment do
  Species.includes(:observations).each do |sp|
    prev = nil
    obs = sp.observations.inject([]) do |memo, ob|
      unless prev.nil?
        memo.push([prev.observ_date, ob.observ_date]) if (ob.observ_date - prev.observ_date) >= 365
      end
      prev = ob
      memo
    end
    unless obs.empty?
      puts "#{sp.name_sci} / #{sp.name_ru}"
      obs.each {|el| puts "  #{el[0]} - #{el[1]} (#{el[1] - el[0]})" }
    end
  end
end