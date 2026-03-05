if Rails.env.development?
  LetterOpener.configure do |config|
    config.location = Rails.root.join("tmp", "my_mails")
    config.message_template = :light

    # Detect WSL vs native Linux
    if File.exist?("/proc/version") && File.read("/proc/version").include?("microsoft")
      # WSL environment
      config.file_uri_scheme = "file://///wsl$/Ubuntu-18.04"
    end
    # Fedora/native Linux will use default file:// scheme
  end
end
