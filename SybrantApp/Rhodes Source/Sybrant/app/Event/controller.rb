require 'rho/rhocontroller'
require 'rho/rhocontact'

#Event controller to create or  manage the events.
class EventController < Rho::RhoController

  #GET /Event
  #Index method used to get all the events.
  def index
    @events = Event.find(:all)
    render
  end

#Getting the events list created by currently logged user.
def myevents
  @events = Event.find(:all)
  render :action=>:myevents
end

#To send invitation for the created events to the selected  Mobile contacts.
def send_invitation
    @total_email_ids=@params
        @total_email_ids.each do |email|
        email_id=Event.new(:email=>email)
        email_id.save        
        end
    SyncEngine::dosync
    render :action=>:send_invitation
end


  # GET /Event/1
  #To show the particular created event by logged user in rhodes. 
  def show
    @event = Event.find(@params['id'])
    @contacts = Rho::RhoContact.find(:all)
    render :action => :show
  end

  # GET /Event/new
  #Create the new event.
  def new
    @event = Event.new
    @pictimelines = PicTimeLine.find(:all)
    render :action => :new
  end

  # GET /Event/1/edit
  #To Edit the selected event.
  def edit
    @event = Event.find(@params['id'])
    render :action => :edit
  end

  # POST /Event/create
  #Create the event in the local mobile database.
  #########################################################
  # To create the images/pictures references in the local mobile database. Currently we are not able to
  #   receive blob reference in the rhosync server. Now we receive as NIL when we inspect BLOB in the
  #   rhosync server. We have already posted this issue for assistance in the RHOMOBILE GOOGLE GROUP.
  #  Following is the reference link "http://groups.google.co.in/group/rhomobile/browse_thread/thread/7cee42e16621e3ed?hl=en#"
  #  So our current application will not be able to  sync the blobs(images) into the  rhosync server.
  #########################################################
  def create
    @event = Event.new(@params['event'])
    @event.userid = '1'
    @event.save
    redirect :action => :index
  end

  # POST /Event/1/update
  #Update the selected event.
  def update
    @event = Event.find(@params['id'])
    @event.update_attributes(@params['event'])
    redirect :action => :index
  end

  # POST /Event/1/delete
  #Delete the selected event.
  def delete
    @event = Event.find(@params['id'])
    @event.destroy
    redirect :action => :index
  end
  
  #To select the picture from the camera control.
    def choose_picture
    Camera::choose_picture(url_for :action => :camera_callback)
    redirect :action => :new
  end

#Callback from mobile pictures.
  def camera_callback
    if @params['status'] == 'ok'
      #create image record in the DB
      image = PicTimeLine.new({'image'=>@params['image_uri']})
      image.save
     # puts "new Image object: " + image.inspect 
   end
   WebView::refresh
    #reply on the callback
    render :action => :ok, :layout => false
  end
  
end
