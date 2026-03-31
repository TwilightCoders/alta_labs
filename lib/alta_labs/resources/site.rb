module AltaLabs
  module Resources
    class Site < Resource
      def list(timezone: nil)
        params = {}
        params[:tz] = timezone if timezone
        get('/api/sites/list', params)
      end

      def find(id:)
        get('/api/site', id: id)
      end

      def stats(id:)
        post('/api/sites/stats', siteid: id)
      end

      def audit(id:)
        get('/api/site/audit', id: id)
      end

      def asn(id:, ip:)
        get('/api/site/asn', id: id, ip: ip)
      end

      def create(name:, type: nil, icon: nil, location: nil)
        params = { name: name }
        params[:type] = type if type
        params[:icon] = icon if icon
        params[:location] = location if location
        post('/api/sites/new', params)
      end

      def rename(id:, name:, icon: nil)
        params = { siteid: id, name: name }
        params[:icon] = icon if icon
        post('/api/sites/rename', params)
      end

      def copy(id:)
        post('/api/sites/copy', siteid: id)
      end

      def delete(id:)
        post('/api/sites/delete', siteid: id)
      end

      def sync(id:)
        post('/api/site/sync', siteid: id)
      end

      def remove_user(id:, user_id:)
        post('/api/sites/remove-user', siteid: id, userid: user_id)
      end
    end
  end
end
