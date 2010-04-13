module CmsEngine
  module UserAssignmentByIdentifier

    # Allow user to be set by an identifier string which should contain their email address

    def user_identifier
      return @instructor_user_name unless @instructor_user_name.blank?
      "#{user.name} (#{user.email})" if user
    end

    def user_identifier=(name)
      @user_identifier = name
      if name =~ /\(([^)]+)\)/
        email_address = $1
        if email_address =~ Authlogic::Regex.email
          self.user = User.find_by_email(email_address)
        end
      end
    end
  
  end
end