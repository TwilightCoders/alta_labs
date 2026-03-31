module AltaLabs
  module Resources
    class ClientDevice < Resource
      def edit(id:, **params)
        post('/api/client/edit', params.merge(id: id))
      end

      def delete(id:)
        post('/api/client/delete', id: id)
      end
    end
  end
end
