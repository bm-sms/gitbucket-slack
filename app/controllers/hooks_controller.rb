class HooksController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :update

  def new
    @hook = Hook.new
  end

  def create
    hook = Hook.new_endpoint(hook_params)

    if hook.save
      redirect_to hook_path(hook)
    else
      render :new
    end
  end

  def show
    @hook = Hook.find(params[:id])
  end

  def update
    if hook = Hook.find(params[:id])
      payload = JSON.parse(params[:payload])

      Rails.logger.info(payload)

      hook.notify(payload)
    end

    render nothing: true
  end

  private

  def hook_params
    params.require(:hook).permit(:slack_hook)
  end
end
