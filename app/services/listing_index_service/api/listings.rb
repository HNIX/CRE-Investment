module ListingIndexService::API

  RELATED_RESOURCES = [:listing_images, :author, :num_of_reviews, :location].to_set

  # TODO Maybe conf+injector?
  # ENGINE = :sphinx
  ENGINE = :zappy

  ListingIndexResult = ListingIndexService::DataTypes::ListingIndexResult

  class Listings

    def search(community_id:, search:, includes: [])

      unless includes.to_set <= RELATED_RESOURCES
        return Result::Error.new("Unknown included resources: #{(includes.to_set - RELATED_RESOURCES).to_a}")
      end

      # s = ListingIndexService::DataTypes.create_search_params(search)
      s = search

      search_result = search_engine.search(
        community_id: community_id,
        search: s,
        includes: includes
      )

      search_result.maybe().map { |res|
        Result::Success.new(
          ListingIndexResult.call(
          count: res[:count],
          listings: res[:listings].map { |search_res|
            search_res.merge(url: "#{search_res[:id]}-#{search_res[:title].to_url}")}))
      }.or_else { |err|
        Result::Error.new(err)
      }
    end

    private

    def search_engine
      case ENGINE
      when :sphinx
        ListingIndexService::Search::SphinxAdapter.new
      when :zappy
        ListingIndexService::Search::ZappyAdapter.new
      else
        raise NotImplementedError.new("Adapter for search engine #{ENGINE} not implemented")
      end
    end
  end

end
