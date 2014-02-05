SEED_TABLES = %w(species loci local_species books taxa)

def seed_init_if_necessary!
  unless seed_inited?
    system("git submodule init")
    system("git submodule update")
  end
end

def seed_inited?
  `git submodule status db/seed | head -c1` != '-'
end
