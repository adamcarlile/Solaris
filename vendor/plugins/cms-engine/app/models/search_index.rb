#
# Allow full text site search powered by Xapian
#
# Engine only indexes Page but other models can be included by adding:
#
#   acts_as_xapian :texts => [:search_text]
#
# Indexed models should implement the following methods:
#
#   * search_text (the text to be included in the index)
#   * title & intro (used in displaying search results)
#   * indexable? (return true if this record should be indexed)
#
# Your indexed model must be registered with this class so it knows to search for that model
#
#    SearchIndex.indexed_classes << MyClass
#
# A helper should be added to allow the search results to link to the appropriate page for your model
#
#   url_for_[model] is automatically called, so for product you must define the helper url_for_product
#
class SearchIndex

  cattr_accessor :indexed_classes
  self.indexed_classes = CmsEngine::Base.page_type_classes.select {|k| k.visitable?}
  
  def self.search_count(query)
    ActsAsXapian::Search.new(indexed_classes, query, :limit => 1).matches_estimated
  end

  def self.search(query, options = {})
    options = {:per_page => 10}.update(options)
    options[:page] ||= 1

    total_matches = ActsAsXapian::Search.new(indexed_classes, query, :limit => options[:per_page]).matches_estimated
    total_pages = (total_matches / options[:per_page].to_f).ceil
    
    offset = options[:per_page] * (options[:page].to_i - 1)
    xapian_search = ActsAsXapian::Search.new(indexed_classes, query, :limit => options[:per_page], :offset => offset)

    results = xapian_search.results.map { |r| r[:model] }

    returning SearchIndex::ResultsCollection.new(options[:page], options[:per_page], total_matches) do |pager|
      pager.xapian_search = xapian_search
      pager.replace results
    end
  end
  
  class ResultsCollection < WillPaginate::Collection
    attr_accessor :xapian_search
    delegate :matches_estimated, :spelling_correction, :words_to_highlight, :to => :xapian_search
  end

end
