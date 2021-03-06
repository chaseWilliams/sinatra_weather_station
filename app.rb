require './router/loader'

class App < Sinatra::Application

  before do
    content_type 'application/json'
  end

  get '/' do
    content_type 'text/html'
    headers 'Location': ENV['ROUTER_URI']
    body RestClient.get ENV['UI_URI'] + request.path_info
  end

  get '/assets/*' do
    data = RestClient.get ENV['UI_URI'] + request.path_info
    headers 'Location': ENV['ROUTER_URI']
    content_type data.headers[:content_type]
    body data
  end

  get '/api' do
    puts ENV['OWM_URI']
    Logger.new(STDOUT).warn 'hello'
    begin
      lat = params[:lat]
      lon = params[:lon]
    rescue StandardError => err
      status 400
      {status: 'fail', reason: err.to_s}.to_json
    else
      weather = JSON.parse RestClient.get ENV['OWM_URI'] + "mode=coordinates&lat=#{lat}&lon=#{lon}"
      wiki_article = JSON.parse RestClient.get ENV['WIKI_URI'] + "lat=#{lat}&lon=#{lon}"
      puts wiki_article
      flickr_url = JSON.parse RestClient.get ENV['FLICKR_URI'] + "temp=#{weather['data']['temp']}" +
                                                              "&id=#{weather['data']['condition_id']}"
      puts flickr_url
      {status: 'ok', weather: weather, article: wiki_article, pic: flickr_url}.to_json
    end
  end

  get '/pure' do
    begin
      lat = params[:lat]
      lon = params[:lon]
    rescue StandardError => err
      status 400
      {status: 'fail', reason: err.to_s}.to_json
    else
      RestClient.get ENV['OWM_URI_PURE'] + "mode=coordinates&lat=#{lat}&lon=#{lon}"
    end
  end

end
