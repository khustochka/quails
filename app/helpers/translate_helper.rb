module TranslateHelper

  def translated(url: nil)
    @translated = true
    @translated_url = url
  end

end
