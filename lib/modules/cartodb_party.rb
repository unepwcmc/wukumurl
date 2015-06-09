class CartodbParty
  include HTTParty

  def self.query query
    get(build_url("/api/v2/sql", {q: query, api_key: CARTODB_CONFIG['api_key']})).parsed_response
  end

  def self.build_url path, opts={}
    uri = URI::HTTPS.build(
      host: "carbon-tool.cartodb.com",
      path: path,
      query: opts.to_query
    )
  end
end
