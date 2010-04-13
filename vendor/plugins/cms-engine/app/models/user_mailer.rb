class UserMailer < ActionMailer::Base
  default_url_options[:host] = "example.org"  

  def account_created(user)
    subject "Your account for #{SITE_NAME} has been created"
    from EMAIL_FROM
    recipients    user.email  
    sent_on       Time.now  
    body          :user => user
  end
  
  def account_activated(user)
    subject "Your account for #{SITE_NAME} is now active"
    from EMAIL_FROM
    recipients    user.email  
    sent_on       Time.now  
    body          :user => user
  end

  def password_reset_instructions(user)
    subject       "Password Reset Instructions"  
    from EMAIL_FROM
    recipients    user.email  
    sent_on       Time.now  
    body          :user => user
  end
  
end
