class TomtomController < ApplicationController

  require 'httpclient'
  require 'uri'
  require 'json'

  MARX_MEADOW_INFO_BOOTH_LAT = 37.770825
  MARX_MEADOW_INFO_BOOTH_LONG = -122.486004
  POLO_FIELD_INFO_BOOTH_LAT = 37.768221
  POLO_FIELD_INFO_BOOTH_LONG = -122.490489

  TOMTOM_API_KEY = "2wxz8qmgvaf3p77nbsbwp7e9"
  GOOGLE_MAPS_API_KEY = "AIzaSyDOW6g8PveQM9NgbUd7R9HC9jaR7PgCJCk"

  def index

    Tracker.track('tomtom', 'Map page loaded')

    return if params[:location].blank? or params[:destination].blank?

    if params[:destination] == "m"
      Tracker.track('tomtom', 'Marx Meadow Map page loaded')
      route = params[:location] + ":" + MARX_MEADOW_INFO_BOOTH_LAT.to_s + "," + MARX_MEADOW_INFO_BOOTH_LONG.to_s
      markers = 'markers=color:blue%7Clabel:M%7C37.770825,-122.486004' +
      '&markers=color:black%7Clabel:*%7C' + params[:location]
      destination = "the Marx Meadow Information Booth"
    else
      Tracker.track('tomtom', 'Polo Field Map page loaded')
      route = params[:location] + ":" + POLO_FIELD_INFO_BOOTH_LAT.to_s + "," + POLO_FIELD_INFO_BOOTH_LONG.to_s
      markers = '&markers=color:red%7Clabel:P%7C37.768221,-122.490489' +
      '&markers=color:black%7Clabel:*%7C' + params[:location]
      destination = "the Polo Field Information Booth"
    end

    url = "https://api.tomtom.com/lbs/services/route/3/" + route + "/Walk/json?key=" + TOMTOM_API_KEY
    
    google_maps_params = {
      'center' => '37.769171,-122.487713',
      'zoom' => '16',
      'size' => '800x500',
      'sensor' => 'true'
    }

    google_maps_url = "http://maps.googleapis.com/maps/api/staticmap?" + google_maps_params.to_query + "&" + markers.gsub(',', '%2C')
    
    begin
      route = JSON.parse(get_page_content(url))

      distance = route["route"]["summary"]["totalDistanceMeters"] * 0.00062137
      time = route["route"]["summary"]["totalTimeSeconds"] / 60

      @message = "You are " + distance.round(2).to_s + " miles away and it will take you about " + time.to_s + " minutes to walk to " + destination

      # current location
      # start = degree_to_tile_number(POLO_FIELD_INFO_BOOTH_LAT, POLO_FIELD_INFO_BOOTH_LONG, 7)
      # new location
      # destination = degree_to_tile_number(MARX_MEADOW_INFO_BOOTH_LAT, MARX_MEADOW_INFO_BOOTH_LONG, 14)

      @gmaps = google_maps_url.gsub('%3A', ':')

      Tracker.track('tomtom', 'API called successfully')
      #render :json => { :gmaps => google_maps_url.gsub('%3A', ':'), :time => time_away_in_minutes, :distance => meters_away_in_miles } and return
    rescue
      Tracker.track('tomtom', 'Exception caught')
      render :json => { :error => "Error! Exception caught!", :url => url } and return
    end

  end

  private
    # fuck this
    def degree_to_tile_number(lat_deg, lon_deg, zoom)
      lat_rad = lat_deg / 180 * 3.141592653589793
      n = 2.0 ** zoom
      xtile = ((lon_deg + 180.0) / 360.0 * n)
      ytile = ((1.0 - Math.log(Math.tan(lat_rad) + (1 / Math.cos(lat_rad))) / Math::PI) / 2.0 * n)
      return { :x => xtile, :y => ytile }
    end

    def get_page_content(url)
      begin
        client = HTTPClient.new
        encoded_url = URI::encode(url)
        event = client.get_content(encoded_url)
      rescue
        return nil
      end
    end

end
