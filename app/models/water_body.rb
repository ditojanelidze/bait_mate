class WaterBody < ApplicationRecord
  WATER_TYPES = %w[lake river reservoir pond stream canal waterfall spring wetland].freeze

  validates :name, presence: true
  validates :water_type, presence: true, inclusion: { in: WATER_TYPES }
  validates :osm_id, presence: true, uniqueness: true
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  scope :by_type, ->(type) { where(water_type: type) if type.present? }

  def display_name
    name_en.presence || name
  end

  def coordinates
    [latitude, longitude]
  end

  def as_map_marker
    {
      id: id,
      name: display_name,
      water_type: water_type,
      latitude: latitude.to_f,
      longitude: longitude.to_f,
      description: description,
      geometry: geometry,
      geometry_type: geometry_type
    }
  end
end
