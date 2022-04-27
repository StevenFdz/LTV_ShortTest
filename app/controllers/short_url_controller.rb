class ShortUrlController < ApplicationController

  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token


  def index
    puts "INDEX"
    short_urls = ShortUrl.order('click_count desc').limit(100);
    render json: { status: "Success", message: "Short URLS Uploaded", data: short_urls}, status: :ok 
  end

  def create
    puts "CREATE"
    url = post_url[:fullurl]
    if validateURL(url)[0] === "200"
      short_url = shorter_url(url)
      fieldCollection = ShortUrl.new({full_url: url, title: short_url})
      if fieldCollection.save
        render json: { status: "Success", message: "Finished", data: fieldCollection}, status: :ok
      else
        render json: { status: "Failed", message: "Finished with Errors", data: fieldCollection.errors}, status: :unprocessable_entity
      end
    else
      render json: { status: "Failed", message: "Finished with Errors. URL invalidated"}, status: :unprocessable_entity
    end
  end

  def show
    puts "SHOW"
    fieldCollection = ShortUrl.where("title = ?", params[:title])
    if update_byId(fieldCollection.pluck(:id)[0], fieldCollection.pluck(:click_count)[0])
      redirect_to fieldCollection.pluck(:full_url)[0]
    else
      render json: { status: "Failed", message: "Finished with Errors"}, status: :unprocessable_entity
    end

  end

  def updated
    puts "UPDATED"
    parameters = put_params
    fieldCollection = ShortUrl.find(parameters[:id])
    if fieldCollection.update_attributes({click_count: parameters[:count]})
      render json: { status: "Success", message: "Finished, field updated", data: fieldCollection}, status: :ok
    else
      render json: { status: "Failed", message: "Finished with Errors", data: fieldCollection.errors}, status: :unprocessable_entity
    end
  end

  def update_byId(id, value)
    fieldCollection = ShortUrl.find(id)
    if fieldCollection.update_attributes({click_count: value+1})
      return true
    else
      return false
    end
  end


  def post_url
    params.permit(:fullurl)
  end

  def put_params
    params.permit(:id, :count)
  end

  def shorter_url(url)
    array = split_url(url)
    short_url = ""
    array.each { |element| short_url = short_url + element[rand(element.length)] }
    fitShortUrl(short_url)
    short_url = short_url + getRecords.to_s
    return short_url
  end

  def split_url(url)
    arr = url.split("/")
    arr.shift()
    arr.shift()
    return arr
  end

  def fitShortUrl(short_url)
    while short_url.length > 3
      short_url.slice!(short_url.length-1)
    end
  end

  def getRecords
    return ShortUrl.count
  end

  def validateURL(url)
    begin 
      require 'open-uri'
      return open(url).status
    rescue
      return ['404', "Not found"]
    end
    
  end


end
