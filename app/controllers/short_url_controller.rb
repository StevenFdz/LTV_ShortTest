class ShortUrlController < ApplicationController

  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token


  def index
    puts "INDEX"
    short_urls = ShortUrl.order('click_count');
    render json: { status: "Success", message: "Short URLS Uploaded", data: short_urls}, status: :ok 
  end

  def create
    puts "CREATE"
    url = post_url[:fullurl]
    puts url 
    #Recuerda hacer la funcion de acortar la URL
    short_url = ShortUrl.new({full_url: url, title: "GOO"})
    if short_url.save
      render json: { status: "Success", message: "Finished", data: short_url}, status: :ok
    else
      render json: { status: "Failed", message: "Finished with Errors", data: short_url.errors}, status: :unprocessable_entity
    end
  end

  def show
    puts "SHOW"
    fieldCollection = ShortUrl.where("title = ?", params[:title])
    redirect_to fieldCollection.pluck(:full_url)[0]

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


  def post_url
    params.permit(:fullurl)
  end

  def put_params
    params.permit(:id, :count)
  end

end
