class PublicController < ApplicationController
  before_filter :get_klass
  before_filter :finder, :except => [:index, :new, :create]
  before_filter :collection_finder, :only => [:index]
  before_filter :init_menu
  
  def index
  end
  
  def show
  end
  
  private

  def collection_finder
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
  
  private
  
  def init_menu
    @current_menuitem = MenuItem.find_by_url(request.request_uri)
    @topmenu_items = MenuItem.find_all.select {|item| item.parent_id == nil }
    unless @current_menuitem.blank?
      @submenu_items = @current_menuitem.absolute_parent.children
    end
  end
end