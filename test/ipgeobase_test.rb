# frozen_string_literal: true

require "test_helper"

class IpgeobaseTest < Minitest::Test
  def setup
    WebMock.disable_net_connect!

    @ip = "83.169.216.199"

    @response = '<?xml version="1.0" encoding="UTF-8"?>
      <query>
          <status>success</status>
          <country>United States</country>
          <countryCode>US</countryCode>
          <region>VA</region>
          <regionName>Virginia</regionName>
          <city>Ashburn</city>
          <zip>20149</zip>
          <lat>39.03</lat>
          <lon>-77.5</lon>
          <timezone>America/New_York</timezone>
          <isp>Google LLC</isp>
          <org>Google Public DNS</org>
          <as>AS15169 Google LLC</as>
          <query>8.8.8.8</query>
      </query>'

    @expected_props = {
      city: "Ashburn",
      country: "United States",
      countryCode: "US",
      lat: "39.03",
      lon: "-77.5"
    }
  end

  def teardown
    remove_request_stub(@stub) unless @stub.nil?
    WebMock.allow_net_connect!
  end

  def test_that_it_has_a_version_number
    refute_nil ::Ipgeobase::VERSION
  end

  def test_it_returns_correct_data
    @stub = stub_request(:get, "http://ip-api.com/xml/#{@ip}").to_return body: @response, headers: { content_type: "application/xml" }

    ip_meta = Ipgeobase.lookup(@ip)

    assert { @expected_props[:city] == ip_meta.city }
    assert { @expected_props[:country] == ip_meta.country }
    assert { @expected_props[:countryCode] == ip_meta.countryCode }
    assert { @expected_props[:lon] == ip_meta.lon }
    assert { @expected_props[:lat] == ip_meta.lat }
  end

  def test_it_throws_with_wrong_url
    assert_raises(Ipgeobase::Error, "Wrong IP format") { Ipgeobase.lookup("jopalala") }
  end
end
