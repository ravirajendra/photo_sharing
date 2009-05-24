require 'rho/rhocontroller'
require 'rho/rhocontact'
 
 #This controller used to manage the mobile contacts.
class ContactController < Rho::RhoController
 
  # GET /Contacts
  #Get all contacts from the mobile.
  def index
    @msg = @params['msg']
    @contacts = Rho::RhoContact.find(:all)
     render
  end

#To save the mobile contacts into the local database for syncing purpose to the specified backend application.
 def local_sync
   @contacts = Rho::RhoContact.find(:all).to_a.sort!{|x,y| x[1]['first_name'] <=> y[1]['first_name'] }
     @contacts.each do |phone_contact|
          check_existance=Contact.find(phone_contact[1]['id'])
              if check_existance.nil?
                  contact=Contact.new(:first_name=>phone_contact[1]['first_name'],:last_name=>phone_contact[1]['last_name'],:company_name=>phone_contact[1]['company_name'],:mobile_number=>phone_contact[1]['mobile_number'],:home_number=>phone_contact[1]['home_number'],:business_number=>phone_contact[1]['business_number'],:email_address=>phone_contact[1]['email_address'])
                  contact.save
              end
       end 
   @msg = "Phone Contacts Saved. "
    redirect :action => :index, :query => {:msg => @msg}   
  end  
  
  
  # GET /Contacts/1
  #To show the selected mobile contact.
  def show
    @contact = Rho::RhoContact.find(@params['id'])
    render :action => :show
  end
 
  # GET /Contacts/new
  #To render the create form of the contact.
  def new
    render :action => :new
  end
 
  # GET /Contacts/1/edit
  #To edit the selected mobile contact.
  def edit
    @contact = Rho::RhoContact.find(@params['id'])
    render :action => :edit
  end
 
   # POST /Contacts
   #To create the new contact into both mobile and local database.
  def create
    @contact = Rho::RhoContact.create!(@params['contact'])
    @mobile_contact = Contact.new(@params['contact'])
    @mobile_contact.save
    redirect :action => :index
  end
 
  # POST /Contacts/1
  #To update the mobile contact both mobile and local database.
  def update
    Rho::RhoContact.update_attributes(@params['contact'])
    @mobile_contact = Contact.new(@params['contact'])
    @mobile_contact.save
    redirect :action => :index
  end
 
  # POST /Contacts/1/delete
  #To delete the contacts in the mobile. 
  def delete
    Rho::RhoContact.destroy(@params['id'])
    redirect :action => :index
  end
 


end