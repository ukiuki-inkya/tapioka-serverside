class TapisController < ApplicationController
  def create
    return render json: { message: "image param is required" }, status: :bad_request if params[:image].nil?

    photo = params[:image]
    @result = yama(photo)

    return render json: { message: "your uploaded image is not tapioka!!!!" }, status: :bad_request if @result.nil?

    render json: @result, status: :ok
  end
  private
  def yama(photo)
    require 'net/http'
    require 'json'
    require 'uri'

    base64 = photo.split("base64,")[1]
    # APIリクエスト用のJSONパラメータの組み立て
    body = {
      requests: [{
        image: {
          content: base64
        },
        features: [
          {
            type: 'LABEL_DETECTION',
            maxResults: 5
          }
        ]
      }]
    }.to_json

    url = "https://vision.googleapis.com/v1/images:annotate?key="
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    response = https.request(request, body)

    JSON.parse(response.body)
  end

end
