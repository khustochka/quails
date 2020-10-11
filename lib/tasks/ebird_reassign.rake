# frozen_string_literal: true

namespace :ebird do
  namespace :location do

    desc "Bulk reassign locations, to get rid of State-level alert"
    task :reassign => :environment do
      require "csv"
      require "ebird/ebird_client"

      data = CSV.parse(File.read(ENV["FILE"]), headers: true)
      hash = data.group_by { |el| [el["Submission ID"], el["Location"]] }
      oldloc = ENV["OLDLOC"]
      list = hash.select { |(id, loc), obs| loc == oldloc }

      client = EbirdClient.new
      client.authenticate
      agent = client.instance_variable_get(:@agent)
      list.to_a.each do |(id, loc), obs|
        locId = obs.first["Location ID"]
        puts "Processing #{id}"
        page = agent.get("https://ebird.org/submit?edit=true&locID=#{locId}&subID=#{id}")
        form = page.form
        form.locID = ENV["NEWLOC"]
        page = agent.submit(form)
        sleep 1.1
      end
    end

  end
end
