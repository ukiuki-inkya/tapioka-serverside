class TapisController < ApplicationController
  def create
    return render json: { message: "image param is required" }, status: :bad_request if params[:image].nil?

    photo = params[:image]
    @result = yama(photo)

    return render json: { message: "your uploaded image is not tpaioka!!!!" }, status: :bad_request if @result.nil?

    render json: @result, status: :ok
  end
end
