# Destroy existing records to avoid duplication
Artist.destroy_all
Lp.destroy_all
Song.destroy_all
Author.destroy_all

User.destroy_all

# Create authors
hetfield = Author.create(name: "James Hetfield")
ulrich = Author.create(name: "Lars Ulrich")
mustaine = Author.create(name: "Dave Mustaine")
hanneman = Author.create(name: "Jeff Hanneman")
king = Author.create(name: "Kerry King")

# Create Artists, LPs, and Songs
metallica = Artist.create(name: "Metallica")
megadeth = Artist.create(name: "Megadeth")
slayer = Artist.create(name: "Slayer")
iron_maiden = Artist.create(name: "Iron Maiden")
black_sabbath = Artist.create(name: "Black Sabbath")

# Metallica Albums
black_album = metallica.lps.create(name: "The Black Album")
black_album.songs.create(title: "Enter Sandman", authors: [hetfield, ulrich])
black_album.songs.create(title: "The Unforgiven", authors: [hetfield])

master_of_puppets = metallica.lps.create(name: "Master of Puppets")
master_of_puppets.songs.create(title: "Battery", authors: [hetfield, ulrich])
master_of_puppets.songs.create(title: "Master of Puppets", authors: [hetfield, ulrich])

# Megadeth Albums
rust_in_peace = megadeth.lps.create(name: "Rust in Peace")
rust_in_peace.songs.create(title: "Holy Wars... The Punishment Due", authors: [mustaine])
rust_in_peace.songs.create(title: "Hangar 18", authors: [mustaine])

# Slayer Albums
reign_in_blood = slayer.lps.create(name: "Reign in Blood")
reign_in_blood.songs.create(title: "Angel of Death", authors: [hanneman, king])
reign_in_blood.songs.create(title: "Raining Blood", authors: [hanneman])

# Iron Maiden Albums
number_of_the_beast = iron_maiden.lps.create(name: "The Number of the Beast")
number_of_the_beast.songs.create(title: "Run to the Hills", authors: [Author.create(name: "Steve Harris")])
number_of_the_beast.songs.create(title: "The Number of the Beast", authors: [Author.create(name: "Steve Harris")])

# Black Sabbath Albums
paranoid = black_sabbath.lps.create(name: "Paranoid")
paranoid.songs.create(title: "Paranoid", authors: [Author.create(name: "Ozzy Osbourne"), Author.create(name: "Tony Iommi")])
paranoid.songs.create(title: "War Pigs", authors: [Author.create(name: "Ozzy Osbourne"), Author.create(name: "Tony Iommi")])

# settings
Setting.set("api", "realm", "Public Api Token")

# users

users = [
  {email: "admin@example.com", password: "Admin123@", roles: [:admin]},
  {email: "user@example.com", password: "User123@", roles: [:user]}
]

users.each do |user_data|
  User.create!(user_data)
end
puts "Seed data created successfully!"
