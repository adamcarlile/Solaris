require File.dirname(__FILE__) + '/../spec_helper'

describe Page do

  before(:all) do
    @global_nav = Factory.create(:top_level_folder)
    User.destroy_all
    @writer = Factory(:user)
    @writer.roles = [Role.writer]
    @editor = Factory(:user)
    @editor.roles = [Role.writer, Role.editor]
  end

  describe "fire_event_with_history_logging" do
    before(:each) do
      BasicPage.destroy_all
      @page = Factory(:page, :parent => @global_nav)
      @page.stubs(:user_can_fire_event?).returns(true)
    end

    it "should fail if event isn't valid because of page's current state" do
      @page.fire_event_with_history_logging(:unpublish, @editor).should be_false
    end
    it "should fail with a none-existing event" do
      @page.fire_event_with_history_logging(:foo, @editor).should be_false
    end

    it "should fail if event is valid but user isn't authorized to fire it" do
      @page.stubs(:user_can_fire_event?).returns(false)
      @page.fire_event_with_history_logging(:submit_for_review, @writer).should be_false
    end

    it "should succeed with valid event and user" do
      @page.fire_event_with_history_logging(:submit_for_review, @writer).should be_true
    end
    
    it "should create publishable_events record with user and transition from/to" do
      @page.publishable_events.count.should == 0
      @page.workflow_comment = 'Comment'
      @page.fire_event_with_history_logging(:publish, @editor)
      @page.publishable_events.count.should == 1
      event = @page.publishable_events.first
      event.to_state.should == 'published'
      event.user.should == @editor
      event.comment.should == 'Comment'
    end
    
    it "should assign the publishable_events record to a user if one is supplied" do
      @page.fire_event_with_history_logging(:publish, @editor, @writer)
      @page.publishable_events.count.should == 1
      @page.publishable_events.first.assigned_user.should == @writer
    end

  end

  
  describe "updating page" do
    before(:each) do
      BasicPage.destroy_all
      @page = Factory(:page, :parent => @global_nav)
      @page.stubs(:user_can_fire_event?).returns(true)
    end
    it "should draft a published page and log the state machine event" do
      @page.update_attribute(:state, 'published')
      @page.reload
      @page.title = 'New title'
      @page.current_user = @writer
      @page.save
      @page.state.should == 'draft'
      @page.publishable_events.count.should == 1
      @page.publishable_events.first.user.should == @writer
    end
  end
  
  describe "publish!" do
    before(:each) do
      BasicPage.destroy_all
      @page = Factory(:page, :parent => @global_nav)
    end
    it "should call publish_latest_version" do
      @page.expects(:publish_latest_version).once
      @page.publish!
    end
  end

  describe "user_can_fire_event?" do
    before(:each) do
      BasicPage.destroy_all
      @page = Factory(:page, :parent => @global_nav)
    end
    describe "with invalid event" do
      it "should be false" do
        @page.user_can_fire_event?(@writer, :foo).should be_false
      end
    end
    describe "with event submit_for_review" do
      it "should be false if user isn't allowed to edit the page" do
        @page.stubs(:editable_by?).returns(false)
        @page.user_can_fire_event?(@writer, :submit_for_review).should be_false
      end
      it "should be true if the user is allowed to edit the page" do
        @page.stubs(:editable_by?).returns(true)
        @page.user_can_fire_event?(@writer, :submit_for_review).should be_true
      end
    end
    describe "with event publish" do
      it "should be false if the user isn't allowed to publish the page" do
        @page.stubs(:publishable_by?).returns(false)
        @page.user_can_fire_event?(@editor, :publish).should be_false
      end
      it "should be true if the user is allowed to publish the page" do
        @page.stubs(:publishable_by?).returns(true)
        @page.user_can_fire_event?(@editor, :publish).should be_true
      end
    end
  end

end
