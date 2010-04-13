module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the homepage/
      '/'
    
    # public paths
    when /the tags page/
      tags_path
    when /the page "(.*)"$/i
      view_page_path($1)

    
    # admin paths
    when /the admin dashboard/
      admin_dashboard_path
    when /the admin pages list/
      admin_pages_path
    when /the edit page screen/
      edit_admin_page_path(@last_updated_page)
    when /the login page/
      login_path

    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
