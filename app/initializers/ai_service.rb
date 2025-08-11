Rails.application.configure do
  if Rails.env.production? && ENV['GROQ_API_KEY'].blank?
    Rails.logger.error("⚠️  GROQ_API_KEY not configured for production environment")
  end
  
  case Rails.env
  when 'development'
    config.ai_model = ENV.fetch('GROQ_MODEL', 'llama3-8b-8192')
  when 'production'
    config.ai_model = ENV.fetch('GROQ_MODEL', 'llama3-70b-8192')
  when 'test'
    config.ai_model = ENV.fetch('GROQ_MODEL', 'llama3-8b-8192')
  end
end

Rails.logger.info("🚀 Groq AI Service initialized with model: #{Rails.application.config.ai_model}")