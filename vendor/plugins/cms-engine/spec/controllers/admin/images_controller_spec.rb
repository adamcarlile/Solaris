require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ImagesController do
  integrate_views

  before(:each) do
    activate_authlogic
    @user = Factory.build(:user, :state => 'active')
    @user.roles = [Role.cms_user, Role.writer]
    UserSession.create! @user
  end

  it "should get index sucessfully" do
    get 'index'
    response.should be_success
  end
  
  it "should get new form sucessfully" do
    get 'new'
    response.should be_success
  end
  
  it "should create sucessfully" do
    Image.any_instance.stubs(:valid?).returns(true)
    post 'create'
    response.should be_redirect
  end

end
