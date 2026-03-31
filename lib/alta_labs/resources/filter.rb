module AltaLabs
  module Resources
    class Filter < Resource
      def get_filter(site_id:)
        get('/api/filter', siteid: site_id)
      end

      def set(site_id:, **params)
        post('/api/filter', params.merge(siteid: site_id))
      end

      def pause(site_id:, **params)
        post('/api/filter/pause', params.merge(siteid: site_id))
      end
    end
  end
end
