class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale] if Settings.available_locales.include? :locale
    else
      accept_langs = request.headers['HTTP_ACCEPT_LANGUAGE'].split(',').map!{ |l| l.split('-')[0].split(';')[0] }
      accept_langs.each do |lang|
        if Settings.available_locales.include? lang
          I18n.locale = lang
          break
        end
      end
    end

  end
end
