module AltaLabs
  module Resources
    class Ssid < Resource
      def list(site_id:)
        get('/api/wifi/ssid/list', siteid: site_id)
      end

      def find(id:)
        get('/api/wifi/ssid', id: id)
      end

      def blob(id:)
        get('/api/wifi/ssid-blob', id: id)
      end

      def create(**params)
        post('/api/wifi/ssid', params)
      end

      def delete(id:)
        post('/api/wifi/ssid/delete', id: id)
      end

      def audit(id:)
        get('/api/wifi/ssid/audit', id: id)
      end

      def sync_template(site_id:)
        post('/api/wifi/ssid-template/sync', siteid: site_id)
      end

      def approve(site_id:, **params)
        post('/api/wifi/approve', params.merge(siteid: site_id))
      end

      def auth_respond(site_id:, event_id:, allow:, timeout: nil)
        params = { siteid: site_id, eventid: event_id, allow: allow }
        params[:timeout] = timeout if timeout
        post('/api/wifi/auth-resp', params)
      end

      def reset_voucher(site_id:, **params)
        post('/api/wifi/voucher/reset', params.merge(siteid: site_id))
      end
    end
  end
end
