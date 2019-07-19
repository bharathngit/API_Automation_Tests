require "swapi" # Ruby helper llibrary for Star wars api
require "json"

module StarWarsMethods

  def verify_character(film_name, char_name)
    puts "verify_character #{char_name} and #{film_name}."
    # Get films resource using swapi helper library method 'get_all'
    films_resource = Swapi.get_all "films"
    # Parse the resource data into Ruby Hash using JSON
    films_json_hash = JSON.parse films_resource
    films_hash = films_json_hash["results"]
    found = false
    for film in films_hash
      puts "Film: #{film["title"]}"

      # For each film in the hash look for the required film_name
      if film["title"]== film_name
        puts "Film found!"
        puts film["title"]
        # for each character in the film look for char_name
        puts "Charaters in this film:"
        for char in film["characters"]
          # User swapi's method 'get_person' to get resource and parse it into a ruby hash
          chars_json_hash = JSON.parse Swapi.get_person(char.gsub!(/\D/, ""))
          puts (chars_json_hash)["name"]
          # Search for the character name equal to char_name
          if (chars_json_hash)["name"]== char_name
            puts "Character found!"
            puts "#{char_name} was in the film!"
            found = true
            break
          end
        end
        break
      end
    end
    if found
      return true
    else
      puts "Character '#{char_name}' not found in the film '#{film_name}'"
      return found
    end
  rescue StandardError => e
    puts e.message
    false
  end

  def verify_starship(ship_name)
    puts "verify_starship #{ship_name} ."
    # Get starship resource using swapi helper library method 'get_all'
    ship_resource = Swapi.get_starship "?search=#{ship_name}"
    # Parse the resource data into Ruby Hash using JSON
    ship_json_hash = JSON.parse ship_resource
    puts ship_json_hash
    ship_hash = ship_json_hash["results"]
    if ship_hash.empty?
      raise "No data found for #{ship_name}"
    else
      puts "#{ship_hash[0]["name"]} is a Starship!"
      true
    end
    rescue StandardError => e
    puts e.message
    false
  end #verify_starship

  def verify_species(person_name, species_type)
    # Get starship resource using swapi helper library method 'get_all'
    people_resource = Swapi.get_person "?search=#{person_name}"
    # Parse the resource data into Ruby Hash using JSON
    people_json_hash = JSON.parse people_resource

    people_hash = people_json_hash["results"]
    puts people_hash
    species_uri = people_hash[0]['species']
    puts species_uri
    if people_hash.empty?
      raise "No data found for #{person_name}"
    else
    # Verify the species
      species_json_hash = JSON.parse Swapi.get_species(species_uri[0].gsub!(/\D/, ""))
      puts species_json_hash
      species_name = species_json_hash["name"]
      if species_name == species_type
        puts "#{person_name} belongs to #{species_type}!"
        return true
      else
        raise "Error!#{person_name} Doesnt belongs to #{species_type}!"
      end
    end
    rescue StandardError => e
    puts e.message
    false
  end #verify_species

  def starships_response_contains(keys_array)
    # Get startships resource using swapi helper library method 'get_all'
    ships_resource = Swapi.get_all "starships"
    # Parse the resource data into Ruby Hash using JSON
    starship_json_hash = JSON.parse ships_resource
    flag = false
    starship_array = starship_json_hash["results"]
    for ship_hash in starship_array
      for exp_key in keys_array
        if ship_hash.key?(exp_key)
          puts "#{exp_key} field exists!"
          flag = true
        else
          puts "#{key} field doesnt exists!"
          flag = false
        end
      end
    end
    flag
    rescue StandardError => e
    puts e.message
    flag
  end #starships_response_contains

  def verify_starship_count
    # Get startships resource using swapi helper library method 'get_all'
    ships_resource = Swapi.get_all "starships"
    # Parse the resource data into Ruby Hash using JSON
    starship_json_hash = JSON.parse ships_resource
    # Get the initial ships count
    ship_count = starship_json_hash["count"]
    puts "Ship count required: #{ship_count}"
    # Set the flag and counters for ships and pages
    has_next = true
    counter = 0
    page_count = 1

    # Loop until there is no next page in "next" key of the hash.
    while(has_next)
      puts "Current page:#{page_count}********************"
      # count the number of ships in the current page
      for ship_hash in starship_json_hash["results"]
        puts ship_hash["name"]
        counter = counter + 1
      end
      # Ship count at the end of current page
      puts "No. of space ships:#{counter}"

      # Check whether there is next page
      if starship_json_hash["next"]!=nil
        puts "Next page exists*******************"
        has_next = true
        page_count = page_count + 1
        # Get the resource and assign it to starship_json_hash
        next_page_ship_resource = Swapi.get_starship "?page=#{page_count}"
        starship_json_hash = JSON.parse next_page_ship_resource
      else
        # Break out of the loop if there are no more pages left
        puts "End of pagination.******************"
        break
      end
    end
    # Compare final count value of 'counter' with initial count value 'ship_count'
    if(counter == ship_count)
      puts "**********Total ship counts matched!***********"
      return true
    else
      puts "**********Total ship counts DID NOT match!***********"
      return false
    end
    rescue StandardError => e
    puts e.message
    false
  end # verify_starship_count
end # module
