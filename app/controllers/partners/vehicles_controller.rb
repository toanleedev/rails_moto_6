module Partners
  class VehiclesController < ApplicationController
    layout 'partner'
    before_action :authenticate_user!
    before_action :set_vehicle, except: %i[index new create destroy_image]
    before_action :set_options, only: %i[new edit]

    def index
      @vehicles = current_user.vehicles.includes(:brand, :type, :engine)
                              .order(created_at: :desc)
    end

    attr_reader :vehicle

    def new
      @vehicle = Vehicle.new
    end

    def show; end

    def create
      @vehicle = current_user.vehicles.new vehicle_params

      if @vehicle.save
        upload_image
        flash[:notice] = t('message.success.create')
        redirect_to edit_partners_vehicle_path(@vehicle)
      else
        set_options
        flash[:alert] = t('message.failure.create')
        render 'new'
      end
    end

    def edit; end

    def update
      if @vehicle.update vehicle_params
        upload_image
        flash[:notice] = t('message.success.update')
        redirect_to edit_partners_vehicle_path(@vehicle)
      else
        flash[:alert] = t('message.failure.update')
        render :edit
      end
    end

    def destroy
      if @vehicle.destroy
        flash[:notice] = t('message.success.destroy')
        redirect_to partners_vehicles_path
      else
        flash[:alert] = t('message.failure.destroy')
        render :edit
      end
    end

    def destroy_image
      vehicle = Vehicle.find_by(id: params[:vehicle_id])
      image = vehicle.vehicle_images.find_by(id: params[:id])
      if image.image_path.file.exists?
        image.image_path.file.delete
        image.destroy
        flash[:notice] = t('message.success.destroy')
      else
        flash[:alert] = t('message.failure.destroy')
      end
      redirect_to request.referrer
    end

    def update_status
      return unless params[:status].present?

      vehicle.status = params[:status]
      if vehicle.save
        flash[:notice] = t('message.success.update')
      else
        flash[:alert] = t('message.failure.update')
      end
      redirect_to partners_vehicle_path(@vehicle)
    end

    def priority
      @priority = vehicle.priorities.new
      @rank_options = [
        [t('.silver_package'), 'silver'],
        [t('.gold_package'), 'gold'],
        [t('.diamon_package'), 'diamon']
      ]
    end

    def priority_create
      priority = vehicle.priorities.new priority_params
      priority.expiry_date = Time.current + 1.month
      priority.status = :offline

      if priority.save
        flash[:notice] = t('message.success.create')
        redirect_to partners_vehicle_path(vehicle)
      else
        flash[:alert] = t('message.failure.create')
        redirect_to priority_partners_vehicle_path(vehicle)
      end
    end

    def priority_upgrade
      redirect_to partners_vehicle_path(@vehicle)
    end

    private

    def vehicle_params
      params.require(:vehicle).permit :name, :description, :price, :year_produce,
                                      :brand_id, :type_id, :engine_id,
                                      images_attributes: %i[id vehicle_id image_path]
    end

    def priority_params
      params.require(:priority).permit :rank, :duration, :amount, :expiry_date
    end

    def upload_image
      return unless params[:images].present?

      params[:images]['image_path'].each do |image|
        @image = @vehicle.vehicle_images.create!(image_path: image)
      end
    end

    def set_vehicle
      @vehicle = Vehicle.includes(:brand, :type, :engine, :user, :priorities)
                        .find_by(id: params[:id])

      return unless @vehicle.blank?

      flash[:alert] = '.vehicle_not_found'
      redirect_to request.referrer
    end

    def set_options
      @vehicle_brands = VehicleOption.brands.pluck(:name_vi, :id)
      @vehicle_types = VehicleOption.types.pluck(:name_vi, :id)
      @vehicle_engines = VehicleOption.engines.pluck(:name_vi, :id)
    end
  end
end