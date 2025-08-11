class AiClient
  include HTTParty
  
  API_ENDPOINT = "https://api.groq.com/openai/v1/chat/completions"
  MAX_RETRIES = 3
  TIMEOUT = 30
  
  def self.call(prompt)
    new.generate_response(prompt)
  end
  
  def initialize
    @api_key = ENV['GROQ_API_KEY']
    raise "GROQ_API_KEY environment variable not set" if @api_key.blank?
  end
  
  def generate_response(prompt)
    retries = 0
    
    begin
      response = make_api_request(prompt)
      
      if response.success?
        content = extract_content(response)
        validate_and_parse_json(content)
      else
        handle_api_error(response)
      end
      
    rescue Net::TimeoutError, HTTParty::Error => e
      retries += 1
      if retries <= MAX_RETRIES
        Rails.logger.warn("AI API retry #{retries}/#{MAX_RETRIES}: #{e.message}")
        sleep(2 ** retries)
        retry
      else
        Rails.logger.error("AI API failed after #{MAX_RETRIES} retries: #{e.message}")
        generate_fallback_response
      end
    rescue => e
      Rails.logger.error("Unexpected AI API error: #{e.message}")
      generate_fallback_response
    end
  end
  
  private
  
  def make_api_request(prompt)
    HTTParty.post(
      API_ENDPOINT,
      headers: {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => 'application/json'
      },
      body: build_request_body(prompt).to_json,
      timeout: TIMEOUT
    )
  end
  
  def build_request_body(prompt)
    {
      model: ENV.fetch('GROQ_MODEL', 'llama3-70b-8192'),
      messages: [
        {
          role: "system",
          content: system_prompt
        },
        {
          role: "user",
          content: prompt
        }
      ],
      max_tokens: 2000,
      temperature: 0.7,
    }
  end
  
  def system_prompt
    <<~PROMPT
      You are a professional League of Legends analyst and coach with deep knowledge of:
      - Current meta champions and builds
      - Item synergies and situational choices
      - Rune optimization for different matchups
      - Strategic gameplay for all phases of the game
      
      IMPORTANT: You MUST respond with ONLY a valid JSON object. Do not include any explanation, markdown, or extra text.
      
      Your response must be a valid JSON object that can be parsed by Ruby's JSON.parse method.
      Always use this exact structure:
      
      {
        "runes": "string describing rune setup",
        "core_items": [{"item": "item name", "description": "why it's good"}],
        "situational_items": [{"item": "item name", "description": "when to use it"}],
        "playstyle_early": "early game strategy",
        "playstyle_mid": "mid game strategy", 
        "playstyle_late": "late game strategy",
        "summary": "overall strategy summary"
      }
      
      Provide practical, actionable advice that considers the specific matchup context.
      Keep descriptions concise but informative.
    PROMPT
  end
  
  def extract_content(response)
    parsed = response.parsed_response
    
    if parsed.dig('choices', 0, 'message', 'content')
      parsed['choices'][0]['message']['content'].strip
    else
      raise "Invalid response structure: #{parsed}"
    end
  end
  
  def validate_and_parse_json(content)
    cleaned_content = extract_json_from_response(content)
    
    parsed = JSON.parse(cleaned_content)
    
    required_fields = %w[runes core_items situational_items playstyle_early playstyle_mid playstyle_late summary]
    missing_fields = required_fields - parsed.keys
    
    if missing_fields.any?
      Rails.logger.warn("AI response missing fields: #{missing_fields}")
      missing_fields.each { |field| parsed[field] = generate_default_value(field) }
    end
    
    parsed.to_json
  end
  
  def extract_json_from_response(content)
    content = content.gsub(/^```json\n?/, '').gsub(/\n?```$/, '')
    
    json_match = content.match(/\{.*\}/m)
    
    if json_match
      json_match[0]
    else
      content.strip
    end
  end
  
  def handle_api_error(response)
    error_info = response.parsed_response
    status_code = response.code
    
    case status_code
    when 401
      raise "Invalid Groq API key"
    when 429
      raise "Groq rate limit exceeded"
    when 500..599
      raise "Groq server error: #{status_code}"
    else
      raise "Groq API error #{status_code}: #{error_info}"
    end
  end
  
  def generate_fallback_response
    Rails.logger.info("Generating fallback AI response")
    
    fallback_data = {
      runes: "Primary: Precision - Conqueror, Triumph, Legend: Alacrity, Last Stand. Secondary: Resolve - Bone Plating, Overgrowth. (AI service unavailable)",
      core_items: [
        {
          item: "Trinity Force",
          description: "Core damage and utility item (AI service unavailable)"
        },
        {
          item: "Sterak's Gage",
          description: "Survivability and damage scaling (AI service unavailable)"
        }
      ],
      situational_items: [
        {
          item: "Guardian Angel",
          description: "When you need survivability in team fights (AI service unavailable)"
        }
      ],
      playstyle_early: "Focus on farming and short trades. AI service was unavailable for detailed analysis.",
      playstyle_mid: "Look for team fight opportunities. AI service was unavailable for detailed analysis.",
      playstyle_late: "Stay with your team and focus objectives. AI service was unavailable for detailed analysis.",
      summary: "AI analysis unavailable - using generic recommendations. Please try again later. (Groq service unavailable)"
    }
    
    fallback_data.to_json
  end
  
  def generate_default_value(field)
    case field
    when 'runes'
      "Rune recommendation unavailable"
    when 'core_items', 'situational_items'
      []
    when 'summary'
      "Analysis incomplete due to technical issues"
    else
      "Information unavailable"
    end
  end
end