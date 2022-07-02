# frozen_string_literal: true

namespace :deflicker do
  desc "Fetch entries from three livejournals"
  task fetch_entries: :environment do
    # For Dreamwidth you need to use not the real password but the API key
    # which can be found/generated here: https://www.dreamwidth.org/manage/emailpost
    [
      ["livejournal.com", "stonechat", "stonechat"],
      ["livejournal.com", "phenolog", "phenolog"],
      ["livejournal.com", "phenolog", "birdlife_ua"],
      ["dreamwidth.org", "whinchat", "whinchat"],
    ].each do |s, u, j|
      server = LiveJournal::Server.new(s, "https://#{s}")
      puts "Enter password for user #{u}@#{s}:"
      passwd = $stdin.gets.strip
      user = LiveJournal::User.new(u, passwd, server)
      user.usejournal = j

      entries = []
      lastsync = nil
      oldlastsync = nil
      loop do
        oldlastsync = lastsync
        preventries = entries.size
        req = LiveJournal::Request::GetEvents.new(user, lastsync: lastsync)
        res = req.run
        entries = res.values
        lastsync = entries.map(&:time).max # .try(:+, 1.minute)
        entries.each do |entry|
          en = Deflicker::JournalEntry.find_or_create_by(user: u, itemid: entry.itemid)
          en.update(
            itemid: entry.itemid,
            anum: entry.anum,
            user: u,
            journal: j,
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
