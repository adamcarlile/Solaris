module ResourceHelpers

  def remember_current_object
    # Remember the last object of a resource controller
    if controller.respond_to?(:model_name) 
      @last_updated_object = controller.send(:end_of_association_chain).first(:order => 'updated_at DESC')
      instance_variable_set("@last_updated_#{controller.send(:model_name)}", @last_updated_object)
    end
  end

  def remember_current_collection
    # Remember the last collection for a resource controller index action
    if controller.respond_to?(:collection)
      @last_collection = controller.send(:object)
      instance_variable_set("@#{controller.send(:model_name).pluralize}", @last_collection)
    end
  end

end
World(ResourceHelpers)
