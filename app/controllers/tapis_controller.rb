# frozen_string_literal: true

class TapisController < ApplicationController
  def create
    return render json: { message: 'image param is required' }, status: :bad_request if params[:image].nil?

    photo = params[:image]
    @result = ishi(yama(photo))

    return render json: { message: 'your uploaded image is not tapioka!!!!' }, status: :bad_request if @result.nil?

    render json: @result, status: :ok
  end

  private

  def yama(photo)
    require 'net/http'
    require 'json'
    require 'uri'

    base64 = photo.split('base64,')[1]
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

    url = 'https://vision.googleapis.com/v1/images:annotate?key='
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    response = https.request(request, body)

    JSON.parse(response.body)
  end

  def ishi(result)
    labels = JSON.parse(result)['labelAnnotations']

    @yasashi = 0.2
    @reisei = 0.2
    @uchiki = 0.2
    @narushisuto = 0.2
    @genki = 0.2

    labels.each do |label|
      @yasashi += label['score'].to_f if label['description'].include?("Milk")
      @reisei += label['score'].to_f if label['description'].include?("Coffee")
      @uchiki += label['score'].to_f if label['description'].include?("Cup")
      @narushisuto += label['score'].to_f if label['description'].include?("Drink")
      @genki += label['score'].to_f if label['description'].include?("FOOD")
    end

    total = @yasashi + @reisei + @uchiki + @narushisuto + @genki

    yasashi_per = (@yasashi / total).to_f
    reisei_per = (@reisei / total).to_f
    uchiki_per = @uchiki / total
    narushisuto_per = @narushisuto / total
    genki_per = @genki / total

    {
      :yasashi => yasashi_per,
      :reisei => reisei_per,
      :uchiki => uchiki_per,
      :narushisuto => narushisuto_per,
      :genki => genki_per
    }
  end
end
