# Intial Setup

    docker-compose build
    docker-compose up mariadb
    # Once mariadb says it's ready for connections, you can use ctrl + c to stop it
    docker-compose run short-app rails db:migrate
    docker-compose -f docker-compose-test.yml build

# To run migrations

    docker-compose run short-app rails db:migrate
    docker-compose -f docker-compose-test.yml run short-app-rspec rails db:test:prepare

# To run the specs

    docker-compose -f docker-compose-test.yml run short-app-rspec

# Run the web server

    docker-compose up

# Adding a URL

    curl -X POST -d "fullurl=https://google.com" http://localhost:3000

    curl -X POST -d "fullurl=https://www.ltvco.com/blog/ltv-work-from-home-six-months-later/" http://localhost:3000

    curl -X POST -d "fullurl=https://www.ltvco.com/careers/costa-rica/" http://localhost:3000

    

# Getting the top 100

    curl localhost:3000

# Checking your short URL redirect

    curl -I localhost:3000/abc

# Explanation of Algorithm for short URLs

    1. Get the complete URL given for the user
    2. Slice the URL by the "/", all the words or subdirectories of the url will be stored in an array
    3. The before action give two('http'/'https', '') fields in the array that aren't usefull for us, so it remove them
    4. Iterate the array created in the step 2, and get one random letter of the word in the index and concat with the final result, this for each index that the array has
    5. Could happens that the URL has a lot of subdirectories so could be possible that the final result in this point has a lot of letters concataned, and this is not the idea, then in the case of the final result has more than 3 letters, the algorithm remove the last letter until the length will be 3
    6. Finally, could happen that the final result will be repeated with another short url created before, so, for avoid this, at end of the final result the algorithm adds the count of registers that there are in the database in this moment
