class Admin::UserPagePermissionsController < Admin::BaseController
  setup_resource_controller
  belongs_to :page

  require_role :admin
  
end
