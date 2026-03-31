module AltaLabs
  module Resources
    class Device < Resource
      def list(site_id:)
        get('/api/device/list', siteid: site_id)
      end

      def add(site_id:, **params)
        post('/api/device/add', params.merge(siteid: site_id))
      end

      def add_serial(site_id:, serial:, **params)
        post('/api/device/add-serial', params.merge(siteid: site_id, serial: serial))
      end

      def edit(id:, **params)
        post('/api/device/edit', params.merge(id: id))
      end

      def delete(id:)
        post('/api/device/delete', id: id)
      end

      def search(query:, **params)
        post('/api/device/search', params.merge(query: query))
      end

      def grab(id:)
        post('/api/device/grab', id: id)
      end

      def release(id:)
        post('/api/device/release', id: id)
      end

      def move(id:, site_id:)
        post('/api/device/move', id: id, siteid: site_id)
      end
    end
  end
end
