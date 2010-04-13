class CustomHtmlFormatter < Cucumber::Formatter::Html

  def inline_css
    @builder.link(:type => 'text/css', :rel => 'stylesheet', :href => 'cucumber.css')
  end

end
