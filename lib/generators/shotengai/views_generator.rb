module Shotengai
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates/views", __FILE__)

      desc "Copy shotengai example views to your application."
      # hide!

      def copy_views
        directory self.class.source_root, 'app/views/shotengai/'
      end
    end
  end
end
