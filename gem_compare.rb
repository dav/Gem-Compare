unless (1..2) === ARGV.size
  puts "Usage: #{__FILE__} <server1> [<server2>]"
  puts "       If only one ssh target is specified, localhost is used as second."
  exit
end

ARGV << 'localhost' if ARGV.size == 1
server1, server2 = ARGV

def get_gems_hash(server)
  list = (server == 'localhost') ? `gem list` : `ssh #{server} gem list`
  hash = {}
  list.split("\n").each do |item|
    item =~ /(\S+) \(([\.\d, ]+)\)/
    gem, versions = $1, $2
    hash[gem] = versions.split(", ")
  end
  hash
end

def display_versions(versions)
  return 'none' if versions.nil?
  versions.sort.join(', ')
end

hash1 = get_gems_hash(server1)
hash2 = get_gems_hash(server2)

keys1 = hash1.keys
keys2 = hash2.keys

all_gems = (keys1 + keys2).uniq

server_name_max_length = [server1.length, server2.length].max

all_gems.sort.each do |gem|
  print "\n#{gem}: "
  if hash1[gem] == hash2[gem]
    puts "identical"
  else
    puts
    printf "  # %#{server_name_max_length}s: %s\n", server1, display_versions(hash1[gem])
    printf "  # %#{server_name_max_length}s: %s\n", server2, display_versions(hash2[gem])
  end
end
