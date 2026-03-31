module AltaLabs
  module Resources
    class Profile < Resource
      def list(site_ids: [])
        post('/api/profile/list', siteids: site_ids)
      end

      def edit(id:, **params)
        post('/api/profile/edit', params.merge(id: id))
      end

      def delete(id:)
        post('/api/profile/delete', id: id)
      end
    end
  end
end
