class IndexController < ApplicationController
  def index
    @tweets = Tweet.order('created_at DESC').limit(20)
  end
end
