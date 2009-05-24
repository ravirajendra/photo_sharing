require 'rho/rhocontroller'

# PicTimeLine controlller to upload or share photos.
class PicTimeLineController < Rho::RhoController
  
  #To get selected images/pictures controls
  def index
    @pictimelines = PicTimeLine.find(:all)
    render
  end
  
  #To display the selected image/picture more details
  def show
    @pictimeline = PicTimeLine.find(@params['id'])
    render :action => :show
  end
  
  # GET /PicTimeLine/new
  #To render the image/picture upload form,
  def new
    @pictimeline = PicTimeLine.find(:all).last || PicTimeLine.new 
    @pictimelines = PicTimeLine.find(:all)
    render :action => :new
  end

#To choose the pictures from the camera control.
  def edit
    Camera::choose_picture(url_for :action => :camera_callback)
    redirect :action => :new
  end

#Callback from mobile camera
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

  # POST /PicTimeLine/create
  #########################################################
  # To create the images/pictures references in the local mobile database. Currently we are not able to
  #   receive blob reference in the rhosync server. Now we receive as NIL when we inspect BLOB in the
  #   rhosync server. We have already posted this issue for assistance in the RHOMOBILE GOOGLE GROUP.
  #  Following is the reference link "http://groups.google.co.in/group/rhomobile/browse_thread/thread/7cee42e16621e3ed?hl=en#"
  #  So our current application will not be able to  sync the blobs(images) into the  rhosync server.
  #########################################################
  def create
    @pictimeline = PicTimeLine.new(@params['pictimeline'])
    p "@pictimeline #{@pictimeline}"
    p "@params #{@params.inspect}"
    @pictimeline.save
    #SyncEngine::dosync
    redirect :action => :index
  end
      
end
