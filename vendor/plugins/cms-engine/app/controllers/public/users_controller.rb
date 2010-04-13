class Public::UsersController < Public::BaseController
  resource_controller
  
  create.flash 'Signup complete'
  create.success.wants.html { redirect_to signup_complete_path }
  update.success.wants.html { redirect_to user_path(current_user) }

end