module OwnedResource
  extend ActiveSupport::Concern

  included do
    before_action :set_owned_resource_collection, only: [ :index ]
    before_action :set_owned_resource_instance, only: [ :show, :edit, :update, :destroy ]
  end

  private

  def resource_name
    controller_name.singularize
  end

  def set_owned_resource_collection
    instance_variable_set("@#{controller_name}", Current.user.public_send(controller_name))
  end

  def set_owned_resource_instance
    resource = Current.user.public_send(controller_name).find(params[:id])
    instance_variable_set("@#{resource_name}", resource)
  end
end
