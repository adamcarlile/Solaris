class Admin::BaseController < CMSController
  
  before_filter :require_user

  require_role :cms_user
  
  layout :set_layout

  helper :easy_forms
  helper :navigation
  helper "admin/filters"
  
  def require_object_editable_by_user
    access_denied unless object.editable_by?(current_user)
  end
  
  def fire_event
    load_object
    object.workflow_comment = params[:comment]
    assigned_user = User.find_by_id(params[:user_id])
    unless object.fire_event_with_history_logging(params[:event].to_s.to_sym, current_user, assigned_user)
      flash[:error] = "Invalid event #{params[:event]}"
    end
    redirect_to edit_object_path
  end

  # For all controllers using ResourceController
  # Call this instead of resource_controller
  # to override various default behaviour
  # Set up pagination when finding collection including automatic filtering of records using named scopes
  def self.setup_resource_controller
    resource_controller
    # Go back to index rather than 'show' after creating or updating
    create.response do |wants|
      wants.html { redirect_to collection_url }
    end
    update.response do |wants|
      wants.html { redirect_to collection_url }
    end
    # Use will_paginate rather than regular find for lists
    define_method :collection do
      paginate_collection_with_filters
    end
    # Override so latest draft version content is shown rather than published content for versioned models
    define_method :object do
      return @object unless @object.nil?
      @object ||= end_of_association_chain.find(param) unless param.nil?
      # Preview content from the latest version or requested version number
      # but only for saved records and only for GET requests 
      # e.g. edit/show when the object is being viewed
      load_version(@object)
      @object
    end

     define_method :load_object do
       if object.respond_to?(:current_user=)
         object.current_user = current_user
       end
       super
     end

    define_method :parent_object do
      if parent? && !parent_singleton?
        @parent_object = parent_model.find(parent_param)
        load_version(@parent_object)
        @parent_object
      else
        nil
      end
    end

  end
  
  
  
  
  # Load the latest version, or a requested version, on the current object or parent object if it is versioned
  def load_version(object_in_question)
    if object_in_question.respond_to?(:preview_latest_version) && !object_in_question.new_record? && request.get?
      if params[:version]
        object_in_question.load_attributes_from_version(params[:version])
      else
        object_in_question.preview_latest_version
      end  
    end
  end
  
  
  #
  # Override these defaults in a RC controller as needed
  #

  def human_model_name
    model_name.humanize
  end

  def list_columns
    [:to_s]
  end

  helper_method :human_model_name, :list_columns

  

  # Handle checkboxes next to file upload widgets were there is an existing file
  def handle_file_deletions(model)
    record = instance_variable_get("@#{model}")
    if params["#{model}_delete"]
      params["#{model}_delete"].keys.each do |column|
        if record.respond_to?(column) and record.send(column) and File.exists?(record.send(column))
          File.delete(record.send(column))
          #record.update_attribute(column, nil)
        end
      end
    end
  end

  def set_layout
    return false if request.xhr?
    if params[:popup] and !params[:popup].blank?
      'admin_dialog'
    else
      'admin'
    end
  end

  #
  # Render a csv file as a download
  # supply array of arrays for data
  # comma separated string for headers
  # filename with no extension
  #
  def render_csv(data,headers,filename)
    csv_writer = ::CSV::Writer.generate(output = '')
    csv_writer << headers.split(',')
    data.each {|row| csv_writer << row}
		send_data(output, :type => "text/plain", :filename => "#{filename}")
  end


end