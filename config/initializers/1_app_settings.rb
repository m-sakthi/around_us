AppSettings = HashWithIndifferentAccess.new(Rails.application.config_for(:app_settings))

def build_url()
  if ![443, 80].include?(AppSettings[:port].to_i)
    custom_port = ":#{AppSettings[:port]}"
  else
    custom_port = nil
  end
  app_path =
    [ AppSettings[:protocol],
      "://",
      AppSettings[:host],
      custom_port,
      AppSettings[:relative_url_root],
    ].join('')
end

AppSettings[:url] = build_url()

AppSettings[:authentication] ||= HashWithIndifferentAccess.new()
AppSettings[:authentication] [:session_expiration_time] ||= 520