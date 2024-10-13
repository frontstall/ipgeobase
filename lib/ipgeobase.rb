# frozen_string_literal: true

require "addressable/template"
require "ipaddress"
require "net/http"
require "happymapper"
require_relative "ipgeobase/version"

module Ipgeobase
  class Error < StandardError; end

  IP_API_URL = "http://ip-api.com/xml"
  ALLOWED_PROPS = %i[city country country_code lon lat].freeze

  @url = Addressable::Template.new("#{IP_API_URL}/{query}")

  def self.lookup(ip)
    raise Error, "Wrong IP format" unless IPAddress.valid? ip

    request_url = @url.expand({ "query" => ip })
    response = Net::HTTP.get(request_url)
    parsed_response = HappyMapper.parse(response)
    props = ALLOWED_PROPS.each_with_object({}) do |prop, result|
      result[prop] = parsed_response.send prop
    end
    LookupData.new(props)
  end

  class LookupData
    attr_reader :city, :country, :countryCode, :lat, :lon

    def initialize(props)
      @city = props[:city]
      @country = props[:country]
      @countryCode = props[:country_code]
      @lon = props[:lon]
      @lat = props[:lat]
    end
  end
end
