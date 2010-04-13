class Admin::UsersController < Admin::BaseController
  setup_resource_controller
  require_role :admin
  before_filter :cant_destroy_self, :only => :destroy
  
  index.response do |wants|
    wants.html {}
    wants.txt { render :text => @users.map{|u| "#{u.name} (#{u.email})"}.join("\n") }
  end  
  
  def cant_destroy_self
    if params[:id].to_i == @current_user.id
      flash[:error] = "You can't delete yourself"
      redirect_to collection_url
      return false
    end
  end

  def list_columns
    [:created_at, :name, :email, :state]
  end
  
  create.before :assign_protected
  update.before :assign_protected
  
  def fire_event
    object.send("#{params[:event]}!")
    flash[:notice] = 'Status updated'
    redirect_to collection_path
  end
  
  protected
    
    def end_of_association_chain
      eoac = User
      eoac = eoac.with_roles(params[:roles]) if params[:roles].present?
      eoac = eoac.with_name_like(params[:name]) if params[:name].present?
      eoac = eoac.with_state(params[:state].to_sym) if params[:state].present?
      eoac
    end
        
    def collection
      if params[:format] == 'txt'
        end_of_association_chain.limit(10)
      else
        paginate_collection_with_filters
      end
    end
    
    def object_params
      params["#{object_name}"] ||= {}
      params["#{object_name}"].tap do |op|
        op[:role_ids] ||= []
      end
    end

    def assign_protected
      object.role_ids = object_params[:role_ids]
      object.state = 'active' # pending state is for public signup
    end

    
end
