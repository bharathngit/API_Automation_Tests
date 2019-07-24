require "swapi" # Ruby helper llibrary for Star wars api
require "json"
require 'logger'
require 'open-uri'

require_relative "logger.rb"


module StarWarsMethods

  def verify_character(film_name, char_name)
    $logger.info(__method__) {"started."}
    $logger.info(__method__) {"verify_character #{char_name} and #{film_name}."}

    # Get films resource using swapi helper library method 'get_all'
    films_resource = Swapi.get_all "films"
    # Parse the resource data into Ruby Hash using JSON
    films_json_hash = JSON.parse films_resource
    films_hash = films_json_hash["results"]
    found = false
    for film in films_hash
      $logger.info(__method__) {"Film: #{film["title"]}"}

      # For each film in the hash look for the required film_name
      if film["title"]== film_name
        $logger.info(__method__) {"Film found!"}
        $logger.info(__method__) {film["title"]}
        # for each character in the film look for char_name
        $logger.info(__method__) {"Charaters in this film:"}
        for char in film["characters"]
          # User swapi's method 'get_person' to get resource and parse it into a ruby hash
          chars_json_hash = JSON.parse Swapi.get_person(char.gsub!(/\D/, ""))
          $logger.info(__method__) {(chars_json_hash)["name"]}
          # Search for the character name equal to char_name
          if (chars_json_hash)["name"]== char_name
            $logger.info(__method__) {"Character found!"}
            $logger.info(__method__) {"#{char_name} was in the film!"}
            found = true
            break
          end
        end
        break
      end
    end
    if found
      $logger.info(__method__) {"ended."}
      return true
    else
      $logger.error(__method__) {"Character '#{char_name}' not found in the film '#{film_name}'"}
      return found
    end
  rescue StandardError => e
    $logger.error(__method__) {e.message}
    false
  end

  def verify_starship(ship_name)
    $logger.info(__method__) {"Searching for #{ship_name} ."}
    # Get starship resource using swapi helper library method 'get_all'
    ship_resource = Swapi.get_starship "?search=#{ship_name}"
    # Parse the resource data into Ruby Hash using JSON
    ship_json_hash = JSON.parse ship_resource
    $logger.info(__method__) {ship_json_hash}
    ship_hash = ship_json_hash["results"]
    if ship_hash.empty?
      raise "No data found for #{ship_name}"
    else
      $logger.info(__method__) {"#{ship_hash[0]["name"]} is a Starship!"}
      true
    end
    rescue StandardError => e
    $logger.error(__method__) {e.message}
    false
  end #verify_starship

  def verify_species(person_name, species_type)
    $logger.info(__method__) {"started."}

    # Get starship resource using swapi helper library method 'get_all'
    people_resource = Swapi.get_person "?search=#{person_name}"
    # Parse the resource data into Ruby Hash using JSON
    people_json_hash = JSON.parse people_resource

    people_hash = people_json_hash["results"]
    $logger.info(__method__) {people_hash}
    species_uri = people_hash[0]['species']
    $logger.info(__method__) {species_uri}
    if people_hash.empty?
      raise "No data found for #{person_name}"
    else
    # Verify the species
      species_json_hash = JSON.parse Swapi.get_species(species_uri[0].gsub!(/\D/, ""))
      $logger.info(__method__) {species_json_hash}
      species_name = species_json_hash["name"]
      if species_name == species_type
        $logger.info(__method__) {"#{person_name} belongs to #{species_type}!"}
        $logger.info(__method__) {"ended."}

        return true
      else
        raise "Error!#{person_name} Doesnt belongs to #{species_type}!"
      end
    end
    rescue StandardError => e
    $logger.error(__method__) {e.message}
    false
  end #verify_species

  def starships_response_contains(keys_array)
    $logger.info(__method__) {"started."}

    # Get startships resource using swapi helper library method 'get_all'
    ships_resource = Swapi.get_all "starships"
    # Parse the resource data into Ruby Hash using JSON
    starship_json_hash = JSON.parse ships_resource
    flag = false
    starship_array = starship_json_hash["results"]
    for ship_hash in starship_array
      for exp_key in keys_array
        if ship_hash.key?(exp_key)
          $logger.info(__method__) {"#{exp_key}"}
          flag = true
        else
          $logger.error(__method__) {"#{key} - false"}
          flag = false
        end
      end
    end
    flag
    rescue StandardError => e
    $logger.error(__method__) {e.message}
    flag
  end #starships_response_contains

  def verify_starship_count
    $logger.info(__method__) {"started."}

    # Get startships resource using swapi helper library method 'get_all'
    ships_resource = Swapi.get_all "starships"
    # Parse the resource data into Ruby Hash using JSON
    starship_json_hash = JSON.parse ships_resource
    # Get the initial ships count
    ship_count = starship_json_hash["count"]
    $logger.info(__method__) {"Ship count required: #{ship_count}"}
    # Set the flag and counters for ships and pages
    has_next = true
    counter = 0
    page_count = 1

    # Loop until there is no next page in "next" key of the hash.
    while(has_next)
      $logger.info(__method__) {"Current page:#{page_count}********************"}
      # count the number of ships in the current page
      for ship_hash in starship_json_hash["results"]
        $logger.info(__method__) {ship_hash["name"]}
        counter = counter + 1
      end
      # Ship count at the end of current page
      $logger.info(__method__) {"No. of space ships:#{counter}"}

      # Check whether there is next page
      if starship_json_hash["next"]!=nil
        $logger.info(__method__) {"Next page exists*******************"}
        has_next = true
        page_count = page_count + 1
        # Get the resource and assign it to starship_json_hash
        next_page_ship_resource = Swapi.get_starship "?page=#{page_count}"
        starship_json_hash = JSON.parse next_page_ship_resource
      else
        # Break out of the loop if there are no more pages left
        $logger.info(__method__) {"End of pagination.******************"}
        break
      end
    end
    # Compare final count value of 'counter' with initial count value 'ship_count'
    if(counter == ship_count)
      $logger.info(__method__) {"**********Total ship counts matched!***********"}
      $logger.info(__method__) {"ended."}
      return true
    else
      $logger.error(__method__) {"**********Total ship counts DID NOT match!***********"}
      $logger.info(__method__) {"ended."}

      return false
    end
    rescue StandardError => e
    $logger.error(__method__) {e.message}
    false
  end # verify_starship_count

  # Mocking API

  # Install JSON Server
  #
  # 'npm install -g json-server'
  #
  # Create a db.json file with some data
  #
  # {
  #   "posts": [
  #     { "id": 1, "title": "json-server", "author": "typicode" }
  #   ],
  #   "comments": [
  #     { "id": 1, "body": "some comment", "postId": 1 }
  #   ],
  #   "profile": { "name": "typicode" }
  # }
  #
  # Start JSON Server
  #
  # 'json-server --watch db.json'
  #
  # Now if you go to http://localhost:3000/posts/1, you'll get
  #
  # { "id": 1, "title": "json-server", "author": "typicode" }
  #
  def verify_mock_api
    $logger.info(__method__) {"started."}
    mock_response_hash = JSON.parse(open("http://localhost:3000/profile?name=typicode").read)
    puts mock_response_hash
    return true unless mock_response_hash.empty?
  rescue OpenURI::HTTPError => h
    $logger.error(__method__) {h.message}
    $logger.error(__method__) {"The resource doesn't exist."}
    false
  end
end # module
