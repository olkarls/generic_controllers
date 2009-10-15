class Admin::AdminController < ApplicationController
  before_filter :get_klass
  before_filter :finder, :except => [:index, :new, :create]
  before_filter :index_finder, :only => [:index]
  layout "admin"
  
  def index
  end
  
  def new
    instance_variable_set "@#{@klass.to_s.downcase}", @klass.new
  end
  
  def show    
  end

  def create
    instance_variable_set "@#{@klass.to_s.downcase}", @klass.new(params["#{@klass.to_s.downcase.intern}"])
    
    respond_to do |format|
      if instance_variable_get("@#{@klass.to_s.downcase}").save
        flash[:success] = I18n.translate("#{@klass.to_s.downcase.intern}") + " " + I18n.translate(:was_successfully_created)
        format.html { redirect_to :action => 'index' }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def edit    
  end
  
  def update
    respond_to do |format|
      if instance_variable_get("@#{@klass.to_s.downcase}").update_attributes(params["#{@klass.to_s.downcase.intern}"])
        flash[:success] = I18n.translate("#{@klass.to_s.downcase.intern}") + " " + I18n.translate(:was_successfully_updated)
        format.html { redirect_to :action => 'index' }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def confirm_destruction    
  end
  
  def destroy
    instance_variable_get("@#{@klass.to_s.downcase}").destroy
    respond_to do |format|
      flash[:success] = I18n.translate("#{@klass.to_s.downcase.intern}") + " " + I18n.translate(:was_successfully_deleted)
      format.html { redirect_to :action => 'index' }
    end
  end
  
  private
  
  def index_finder
    if @klass.inspect.include?('title')
      instance_variable_set "@#{collection_name}", @klass.paginate(:page => params[:page] || 1, :order => :title)
    else
      instance_variable_set "@#{collection_name}", @klass.paginate(:page => params[:page] || 1)
    end
  end
  
  def finder
    if @klass.inspect.include?('permalink')
      instance_variable_set "@#{@klass.to_s.downcase}", @klass.find_by_permalink(params[:id])
    else
      instance_variable_set "@#{@klass.to_s.downcase}", @klass.find(params[:id])
    end
  end

  def get_klass
    klass_name = controller_name.to_s.singularize.titlecase.gsub(' ','')
    begin
      if Kernel.const_get(klass_name)
        @klass = klass_name.constantize
      end
    rescue
      @klass = nil
    end
  end
  
  def collection_name
    @klass.to_s.pluralize.downcase
  end
end