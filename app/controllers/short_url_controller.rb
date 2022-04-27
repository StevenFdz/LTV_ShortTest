class ShortUrlController < ApplicationController

  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token


  def index                                                                     #Function when call GET localhost:3000
    short_urls = ShortUrl.order('click_count desc').limit(100);                 #Do a request in the DT, the result will be the top 100 sites most visited
    render json: { status: "Success", message: "Short URLS Uploaded", data: short_urls}, status: :ok 
  end

  def create                                                                    #Function when call POST localhost:3000
    url = post_url[:fullurl]                                                    #Get the url that the user send in the params
    if validateURL(url)[0] === "200"                                            #Validate the URL
      short_url = shorter_url(url)
      fieldCollection = ShortUrl.new({full_url: url, title: short_url})         #Create a new instance of the model ShortUrl
      if fieldCollection.save                                                   #Save the instance in the Database
        render json: { status: "Success", message: "Finished", data: fieldCollection}, status: :ok
      else                                                                      #When the register won't save send this error
        render json: { status: "Failed", message: "Finished with Errors", data: fieldCollection.errors}, status: :unprocessable_entity
      end
    else
      render json: { status: "Failed", message: "Finished with Errors. URL invalidated"}, status: :unprocessable_entity
    end
  end

  def show                                                                                #Function when call GET localhost:3000/short_url_code
    fieldCollection = ShortUrl.where("title = ?", params[:title])                         #Get the register that has the short_url that has coincidence with the short_url introduced for the user
    if update_byId(fieldCollection.pluck(:id)[0], fieldCollection.pluck(:click_count)[0]) #Update the click_count of the register chosen
      redirect_to fieldCollection.pluck(:full_url)[0]                                     #If everything works ok redirect to the website
    else
      render json: { status: "Failed", message: "Finished with Errors"}, status: :unprocessable_entity  #If something works bad sends an error
    end

  end

  def updated     #This funcions is not neccesary for the requirements but I created for did it tests 
    puts "UPDATED"
    parameters = put_params                                                     #Get the params of the url
    fieldCollection = ShortUrl.find(parameters[:id])                            #Get by id one register from the DB
    if fieldCollection.update_attributes({click_count: parameters[:count]})     #Update the register
      render json: { status: "Success", message: "Finished, field updated", data: fieldCollection}, status: :ok
    else
      render json: { status: "Failed", message: "Finished with Errors", data: fieldCollection.errors}, status: :unprocessable_entity
    end
  end


  def update_byId(id, value)      
    #Update the column "click_count" by the ID of it. Additionaly recieve an value that corresponds the amount of click_count of the page
    fieldCollection = ShortUrl.find(id)                           #Found the register for update
    if fieldCollection.update_attributes({click_count: value+1})  #Do the update, add + 1 because when this function execute means that one user use the short_url of the register
      return true                                                 #Return true if everything works ok
    else
      return false                                                #Return false if something works bad
    end
  end

  ######################################################################################
  ###Validation of url parameters, only permit the parameters that the function needs

  def post_url  
    params.permit(:fullurl)
  end

  def put_params
    params.permit(:id, :count)
  end

  #######################################################################################
  ######Short URL algorithm


  def shorter_url(url)                                        #Main function of the algorithm, recieves the URL that we want to short
    array = split_url(url)  
    short_url = ""        
    array.each { |element| short_url = short_url + element[rand(element.length)] }  #Iterate the array of subdirectories and get one random letter of it, the letter is concatenated to the result 
    fitShortUrl(short_url)
    short_url = short_url + getRecords.to_s
    return short_url
  end


  def split_url(url)                                          #Create the array with the subdirectories of the url
    arr = url.split("/")
    ###################
    #This lines remove the first two fields of the array. Because they don't useful for the algorithm
    arr.shift()
    arr.shift()
    ###################
    return arr
  end

  def fitShortUrl(short_url)                                  #This function short the short_urls that its lenght is upper than 3
    while short_url.length > 3
      short_url.slice!(short_url.length-1)
    end
  end

  def getRecords                                             #Request for the database, return the amount of record that the database has
    return ShortUrl.count
  end

  ############################################################################################

  def validateURL(url)    
    begin 
      require 'open-uri'                                    #Import the library for test the url that the user introduces
      return open(url).status                               #This function open the url, if it isn't work, the function goes to the rescue
    rescue
      return ['404', "Not found"]                           #Return an error
    end
    
  end


end
