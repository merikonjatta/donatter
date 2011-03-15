class IndexController < ApplicationController
  def index
    system("ruby #{Rails.root}/script/collector_server_ctl.rb start")
    @tweets = Tweet.order('created_at DESC').limit(20)
  end
end
