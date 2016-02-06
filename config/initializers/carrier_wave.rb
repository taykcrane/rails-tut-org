if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Configuration for Amazon S3
      :provider              => 'AWS',
      #for user "taylor"
      :aws_access_key_id     => ENV['AKIAJOIYE4CNABOIDVGQ'],
      :aws_secret_access_key => ENV['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']
    }
    config.fog_directory     =  ENV['rails-tutorial-taykcrane']
  end
end