# Silence deprecation warnings
Rails.application.config.dartsass.build_options |= [ "--silence-deprecation=import,global-builtin,color-functions" ]
