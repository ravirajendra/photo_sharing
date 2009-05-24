require 'rho'
require 'rho/rhocontroller'

class LoginController < Rho::RhoController
  
  def index
  @msg = @params['msg']
  render :action => :create
  #~ @param_check=""
      #~ if @params[:user]
        #~ @user=@params[:user]
      #~ else  
      #~ @user=[]
      #~ end
    #~ render
  end

  def login
    
    @msg = @params['msg']
    render :action => :login
  end
  
  def logout
    SyncEngine::logout
    @msg = "You have been logged out."
    render :action => :login, :query => {:msg => @msg}
  end
  
  def reset
    render :action => :reset
  end
  
  def do_reset
    SyncEngine::trigger_sync_db_reset
    SyncEngine::dosync
    @msg = "Database has been reset."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def do_sync
    SyncEngine::dosync
    @msg =  "Sync has been triggered."
    redirect :action => :index, :query => {:msg => @msg}
  end

  def sucess
   # render :action => :sucess
  end

  def failure
    #  render :action => :failure
  end
    
  def login_backend_app
    @param_check=@params[:username]
     @user = User.find(:all)
     User.new()
     render :action=>:index
     
     
     #~ if @user
          #~ render :action=>:sucess
        #~ else
           #~ render :action=>:failure
      #~ end
  end
  
end
