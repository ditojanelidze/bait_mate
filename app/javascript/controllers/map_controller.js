import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        markers: Array,
        centerLat: Number,
        centerLng: Number,
        zoom: Number
    }

    connect() {
        this.initializeMap()
        this.addWaterBodies()
        this.setupFilterButtons()
    }

    initializeMap() {
        this.map = L.map(this.element).setView(
            [this.centerLatValue, this.centerLngValue],
            this.zoomValue
        )

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(this.map)

        this.featureLayer = L.layerGroup().addTo(this.map)
        this.allFeatures = []
    }

    getColor(waterType) {
        const colors = {
            lake: '#3b82f6',
            river: '#6366f1',
            reservoir: '#06b6d4',
            pond: '#10b981',
            stream: '#8b5cf6',
            canal: '#ec4899',
            spring: '#84cc16',
            waterfall: '#ef4444',
            wetland: '#a855f7'
        }
        return colors[waterType] || '#3b82f6'
    }

    addWaterBodies() {
        this.markersValue.forEach(data => {
            const color = this.getColor(data.water_type)
            let feature

            if (data.geometry && data.geometry.length > 0) {
                if (data.geometry_type === 'polygon' ||
                    data.water_type === 'lake' ||
                    data.water_type === 'reservoir' ||
                    data.water_type === 'pond') {
                    // Render as polygon
                    feature = L.polygon(data.geometry, {
                        color: color,
                        weight: 2,
                        opacity: 0.8,
                        fillColor: color,
                        fillOpacity: 0.4
                    })
                } else {
                    // Render as polyline (rivers, streams, canals)
                    feature = L.polyline(data.geometry, {
                        color: color,
                        weight: 3,
                        opacity: 0.8
                    })
                }
            } else {
                // Render as marker for points (springs, waterfalls, or items without geometry)
                feature = L.marker([data.latitude, data.longitude], {
                    icon: this.createIcon(data.water_type)
                })
            }

            feature.bindPopup(this.createPopupContent(data))
            feature.waterType = data.water_type
            feature.waterData = data

            this.allFeatures.push(feature)
            this.featureLayer.addLayer(feature)
        })
    }

    createIcon(waterType) {
        const color = this.getColor(waterType)

        return L.divIcon({
            className: 'custom-marker',
            html: `<div style="
                background-color: ${color};
                width: 20px;
                height: 20px;
                border-radius: 50%;
                border: 2px solid white;
                box-shadow: 0 2px 4px rgba(0,0,0,0.3);
            "></div>`,
            iconSize: [20, 20],
            iconAnchor: [10, 10],
            popupAnchor: [0, -10]
        })
    }

    createPopupContent(data) {
        const description = data.description
            ? `<p class="text-sm text-gray-600 mt-2">${data.description}</p>`
            : ''

        return `
            <div class="water-popup">
                <h3>${data.name}</h3>
                <span class="water-type water-type-${data.water_type}">${data.water_type}</span>
                ${description}
            </div>
        `
    }

    setupFilterButtons() {
        const buttons = document.querySelectorAll('.filter-btn')

        buttons.forEach(button => {
            button.addEventListener('click', (e) => {
                const filter = e.target.dataset.filter

                buttons.forEach(btn => {
                    btn.classList.remove('bg-blue-600', 'text-white', 'active')
                    btn.classList.add('bg-gray-200', 'text-gray-700')
                })

                e.target.classList.remove('bg-gray-200', 'text-gray-700')
                e.target.classList.add('bg-blue-600', 'text-white', 'active')

                this.filterFeatures(filter)
            })
        })
    }

    filterFeatures(filter) {
        this.featureLayer.clearLayers()

        this.allFeatures.forEach(feature => {
            if (filter === 'all' || feature.waterType === filter) {
                this.featureLayer.addLayer(feature)
            }
        })
    }

    disconnect() {
        if (this.map) {
            this.map.remove()
        }
    }
}
