module ListingIndexService::Search

  class ZappyAdapter < SearchEngineAdapter

   def initialize
     @conn = Faraday.new(url: "http://127.0.0.1:8080") do |c|
        c.request  :url_encoded             # form-encode POST params
        c.response :logger                  # log requests to STDOUT
        c.response :json                    # Parse JSON response

        c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
     end
   end

   def search(community_id:, search:, includes: nil)

     begin
       res = @conn.get('/search', {community_id: community_id, keywords: search[:keywords]}).body
       Result::Success.new({count: res.count, listings: res.map { |l| HashUtils.symbolize_keys(l) }})
     rescue StandardError => e
       Result::Error.new(e)
     end
   end
  end
end
