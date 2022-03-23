module SetAppConfiguration

  private

  # Set the Application Configuration
  # This can be used in before actions.
  # Ex:
  #   before_action :set_app_config, only: [:edit, :update]
  #
  def set_app_config
    @app_configuration = AdminOnly::AppConfiguration.config_to_use
  end

end
