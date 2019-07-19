require 'logger'
require_relative "../lib/start_wars/swapi_lib"
require_relative "../lib/start_wars/logger"
include StarWarsMethods
RSpec.describe StartWars do

  it "Assert that Obi-Wan Kenobi was in the film A New Hope" do
    $logger.info {"Test 1. Assert that Obi-Wan Kenobi was in the film A New Hope"}
    expect(true).to eq(verify_character("A New Hope", "Obi-Wan Kenobi"))
  end

  it "Assert that the Enterprise is a starship (yes, this should fail)" do
    $logger.info {"Test 2. Assert that the Enterprise is a starship (yes, this should fail)"}
    expect(verify_starship("Enterprise")).to eq(false)
  end

  it "Assert that Chewbacca is a Wookiee" do
    $logger.info {"Test 3. Assert that Chewbacca is a Wookiee"}
    expect(verify_species("Chewbacca","Wookiee")).to eq(true)
  end

  it "Assert that the /starships endpoint returns the fields below:
      ○ name
      ○ model
      ○ crew
      ○ hyperdrive_rating
      ○ pilots
      ○ films" do
    $logger.info {"Test 4. Assert that the /starships endpoint returns the fields"}
    expect(starships_response_contains(["name","model","crew","hyperdrive_rating","pilots","films"])).to eq(true)
  end

  it "Assert that the /starships count returned is correct by paging through the results" do
    $logger.info {"Test 5.Assert that the /starships count returned is correct by paging through the results"}
    expect(verify_starship_count).to eq(true)
  end
end
