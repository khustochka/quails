namespace :deflicker do

  desc "Fetch entries from three livejournals"
  task :fetch_entries => :environment do

    # For Dreamwidth you need to use not the real password but the API key
    # which can be found/generated here: https://www.dreamwidth.org/manage/emailpost
    [
        ["livejournal.com", "stonechat"],
        ["livejournal.com", "phenolog"],
        ["dreamwidth.org", "whinchat"]
    ].each do |s, u|
      server = LiveJournal::Server.new(s, "https://#{s}")
      puts "Enter password for user #{u}:"
      passwd = STDIN.gets.strip
      user = LiveJournal::User.new(u, passwd, server)

      entries = []
      lastsync = nil
      oldlastsync = nil
      loop do
        oldlastsync = lastsync
        preventries = entries.size
        req = LiveJournal::Request::GetEvents.new(user, lastsync: lastsync)
        res = req.run
        entries = res.values
        lastsync = entries.map(&:time).max #.try(:+, 1.minute)
        entries.each do |entry|
          en = Deflicker::JournalEntry.find_or_create_by(user: u, itemid: entry.itemid)
          en.update(
              itemid: entry.itemid,
              anum: entry.anum,
              user: u,
              server: s,
              event: entry.event,
              subject: entry.subject&.force_encoding("UTF-8"),
              time: entry.time
          )
          en.extract_images_links
        end
        break if entries.empty? || (preventries > 0 && entries.size > preventries) || oldlastsync == lastsync
      end

    end

  end

end
