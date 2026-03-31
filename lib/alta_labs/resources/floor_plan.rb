module AltaLabs
  module Resources
    class FloorPlan < Resource
      def floors(site_id:)
        get('/api/floor-plan/floors', siteid: site_id)
      end

      def create_floor(**params)
        post('/api/floor-plan/floor', params)
      end

      def delete_floor(id:)
        post('/api/floor-plan/delete-floor', id: id)
      end

      def devices(site_id:)
        get('/api/floor-plan/devices', siteid: site_id)
      end

      def walls(site_id:)
        get('/api/floor-plan/walls', siteid: site_id)
      end
    end
  end
end
