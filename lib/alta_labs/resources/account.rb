module AltaLabs
  module Resources
    class Account < Resource
      def info
        post_authenticated('/api/account/info')
      end

      def list
        post_authenticated('/api/account/list')
      end

      def update(**params)
        post_authenticated('/api/account/update', params)
      end
    end
  end
end
