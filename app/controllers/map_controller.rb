class MapController < ApplicationController
  def index
    @water_bodies = WaterBody.all
    @markers = @water_bodies.map(&:as_map_marker)
  end

  def water_bodies
    water_bodies = WaterBody.all
    water_bodies = water_bodies.by_type(params[:type]) if params[:type].present?

    render json: water_bodies.map(&:as_map_marker)
  end
end
