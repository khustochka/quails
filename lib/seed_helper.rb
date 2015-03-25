SEED_TABLES = %w(species loci local_species books taxa)

SEED_DIR = File.join(ENV["HOME"], 'bwseed')
SEED_REPO = "https://gist.github.com/8771462.git"

def seed_init_if_necessary!
  unless seed_inited?
    system("git clone #{SEED_REPO} #{SEED_DIR}")
  end
end

def seed_inited?
  File.exists?(SEED_DIR)
end
