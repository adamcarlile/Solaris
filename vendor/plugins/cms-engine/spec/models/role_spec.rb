require File.dirname(__FILE__) + '/../spec_helper'

describe Role do

  before(:each) do
  end

  describe "role accessor method" do
    
    it "should return the role with the right name" do
      Role.admin.name.should == 'admin'
    end

  end

end
