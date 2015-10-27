# Stores articles from all importers
class Article < ActiveRecord::Base
  # prevents duplicates on the basis of title
  validates_uniqueness_of :title

  # articles have a tag_list attribute
  acts_as_taggable

  # many articles belong to one source
  belongs_to :source

  # This method searches through the articles, given an input,
  # in order of weight, then publication date
  def self.search(search, articles)
    weights = {}

    articles.each do |article|
      weighting = 0
      weight_map = { article.tag_list => 4, article.title => 3, article.summary => 2, article.source.name => 1 }
      # Search for just words in the search box
      # Searching is case insenstive
      regex = /#{search}/i

      weight_map.each do |k, w|
        attribute = k
        next unless attribute?nil
        if attribute.is_a?(Array)
          attribute.each do |e|
            next unless e.scan(regex).length > 0
            weighting += w
            break
          end
        elsif attribute.is_a?(String)
          next unless attribute.scan(regex).length > 0
          weighting += w
          break
        end
      end

      next unless weighting > 0
      weights[article] = weighting
    end

    # Sort by weight, then by date on matching weights
    weights = weights.sort_by {|k, v| [v, k.pub_date]}.reverse.to_h

    # Return the articles as an array
    searched_articles = weights.keys
  end
end
