namespace :water_bodies do
  desc "Fetch water bodies in Georgia from OpenStreetMap with full geometry"
  task fetch: :environment do
    require "net/http"
    require "json"

    # Helper lambdas
    determine_water_type = ->(tags) do
      if tags["water"]
        case tags["water"]
        when "lake" then "lake"
        when "reservoir" then "reservoir"
        when "pond" then "pond"
        end
      elsif tags["waterway"]
        case tags["waterway"]
        when "river" then "river"
        when "stream" then "stream"
        when "canal" then "canal"
        when "waterfall" then "waterfall"
        end
      elsif tags["natural"] == "spring"
        "spring"
      end
    end

    extract_geometry = ->(element) do
      case element["type"]
      when "node"
        {
          type: "point",
          center: [element["lat"], element["lon"]],
          coordinates: nil
        }
      when "way"
        if element["geometry"]
          coords = element["geometry"].map { |p| [p["lat"], p["lon"]] }
          center = calculate_center(coords)
          {
            type: "linestring",
            center: center,
            coordinates: coords
          }
        else
          { type: "point", center: [element["lat"], element["lon"]], coordinates: nil }
        end
      when "relation"
        if element["members"]
          all_coords = []
          element["members"].each do |member|
            next unless member["geometry"]
            member["geometry"].each do |p|
              all_coords << [p["lat"], p["lon"]]
            end
          end
          if all_coords.any?
            center = calculate_center(all_coords)
            {
              type: "polygon",
              center: center,
              coordinates: all_coords
            }
          else
            { type: "point", center: [element["lat"], element["lon"]], coordinates: nil }
          end
        else
          { type: "point", center: [element["lat"], element["lon"]], coordinates: nil }
        end
      else
        { type: "point", center: [nil, nil], coordinates: nil }
      end
    end

    puts "Fetching water bodies from OpenStreetMap with full geometry..."

    # Overpass API endpoint
    overpass_url = URI("https://overpass-api.de/api/interpreter")

    # Overpass QL query for water bodies in Georgia with full geometry
    query = <<~OVERPASS
      [out:json][timeout:300];
      area["ISO3166-1"="GE"]->.georgia;
      (
        // Lakes
        node["natural"="water"]["water"="lake"](area.georgia);
        way["natural"="water"]["water"="lake"](area.georgia);
        relation["natural"="water"]["water"="lake"](area.georgia);

        // Reservoirs
        node["natural"="water"]["water"="reservoir"](area.georgia);
        way["natural"="water"]["water"="reservoir"](area.georgia);
        relation["natural"="water"]["water"="reservoir"](area.georgia);

        // Rivers
        way["waterway"="river"](area.georgia);
        relation["waterway"="river"](area.georgia);

        // Ponds
        node["natural"="water"]["water"="pond"](area.georgia);
        way["natural"="water"]["water"="pond"](area.georgia);

        // Streams
        way["waterway"="stream"](area.georgia);

        // Canals
        way["waterway"="canal"](area.georgia);

        // Springs
        node["natural"="spring"](area.georgia);

        // Waterfalls
        node["waterway"="waterfall"](area.georgia);
        way["waterway"="waterfall"](area.georgia);
      );
      out body geom;
    OVERPASS

    begin
      puts "Sending request to Overpass API (this may take a few minutes)..."

      http = Net::HTTP.new(overpass_url.host, overpass_url.port)
      http.use_ssl = true
      http.read_timeout = 600
      http.open_timeout = 60

      request = Net::HTTP::Post.new(overpass_url)
      request["Content-Type"] = "application/x-www-form-urlencoded"
      request.body = "data=#{URI.encode_www_form_component(query)}"

      response = http.request(request)

      if response.code != "200"
        puts "Error: Received HTTP #{response.code}"
        puts response.body[0..500]
        exit 1
      end

      data = JSON.parse(response.body)
      elements = data["elements"]

      puts "Found #{elements.length} water body elements"

      imported = 0
      updated = 0
      skipped = 0

      elements.each do |element|
        osm_id = element["id"]
        tags = element["tags"] || {}

        # Get name - skip if no name
        name = tags["name"]
        next if name.blank?

        # Determine water type
        water_type = determine_water_type.call(tags)
        next if water_type.nil?

        # Extract geometry
        geo = extract_geometry.call(element)
        next if geo[:center][0].nil? || geo[:center][1].nil?

        # Prepare attributes
        attrs = {
          name: name,
          name_en: tags["name:en"],
          water_type: water_type,
          latitude: geo[:center][0],
          longitude: geo[:center][1],
          description: tags["description"],
          area: tags["area"]&.to_f,
          geometry: geo[:coordinates],
          geometry_type: geo[:type]
        }

        # Find or create
        water_body = WaterBody.find_by(osm_id: osm_id)

        if water_body
          water_body.update!(attrs)
          updated += 1
        else
          WaterBody.create!(attrs.merge(osm_id: osm_id))
          imported += 1
        end

      rescue ActiveRecord::RecordInvalid => e
        puts "Skipping invalid record (OSM ID: #{osm_id}): #{e.message}"
        skipped += 1
      end

      puts ""
      puts "Import complete!"
      puts "  New records: #{imported}"
      puts "  Updated records: #{updated}"
      puts "  Skipped: #{skipped}"
      puts "  Total in database: #{WaterBody.count}"
      puts ""
      puts "Geometry breakdown:"
      WaterBody.group(:geometry_type).count.each do |type, count|
        puts "  #{type || 'none'}: #{count}"
      end

    rescue StandardError => e
      puts "Error fetching data: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      exit 1
    end
  end

  desc "Clear all water bodies from the database"
  task clear: :environment do
    count = WaterBody.count
    WaterBody.delete_all
    puts "Deleted #{count} water bodies"
  end

  desc "Show water body statistics"
  task stats: :environment do
    puts "Water Body Statistics:"
    puts "-" * 40
    puts "Total: #{WaterBody.count}"
    puts ""
    puts "By type:"
    WaterBody.group(:water_type).count.sort_by { |_, v| -v }.each do |type, count|
      puts "  #{type}: #{count}"
    end
    puts ""
    puts "By geometry:"
    WaterBody.group(:geometry_type).count.sort_by { |_, v| -v }.each do |type, count|
      puts "  #{type || 'none'}: #{count}"
    end
  end
end

def calculate_center(coords)
  return [nil, nil] if coords.empty?
  lat_sum = coords.sum { |c| c[0] }
  lon_sum = coords.sum { |c| c[1] }
  [lat_sum / coords.length, lon_sum / coords.length]
end
