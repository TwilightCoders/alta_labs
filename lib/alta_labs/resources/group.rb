module AltaLabs
  module Resources
    class Group < Resource
      def add(site_id:, **params)
        post('/api/group/add', params.merge(siteid: site_id))
      end

      def edit(id:, **params)
        post('/api/group/edit', params.merge(id: id))
      end

      def delete(id:)
        post('/api/group/delete', id: id)
      end
    end
  end
end
