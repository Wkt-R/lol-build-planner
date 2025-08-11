namespace :ai do
  desc "Test Groq AI service integration"
  task test: :environment do
    puts "🚀 Testing Groq AI Service Integration..."
    
    test_matchup = Matchup.new(
      user_champion: "Jinx",
      user_role: "ADC",
      ally_team: [
        { champion: "Garen", role: "TOP" },
        { champion: "Graves", role: "JUNGLE" },
        { champion: "Yasuo", role: "MID" },
        { champion: "Thresh", role: "SUPPORT" }
      ],
      enemy_team: [
        { champion: "Darius", role: "TOP" },
        { champion: "Lee Sin", role: "JUNGLE" },
        { champion: "Zed", role: "MID" },
        { champion: "Caitlyn", role: "ADC" },
        { champion: "Lux", role: "SUPPORT" }
      ]
    )
    
    begin
      puts "📝 Generating prompt..."
      prompt = PromptBuilder.new(test_matchup).generate
      puts "✅ Prompt generated successfully"
      puts "📏 Prompt length: #{prompt.length} characters"
      
      puts "\n🔮 Calling AI service..."
      start_time = Time.current
      
      response = AiClient.call(prompt)
      
      end_time = Time.current
      puts "✅ AI response received in #{(end_time - start_time).round(2)} seconds"
      
      puts "\n📊 Parsing response..."
      parsed = JSON.parse(response)
      
      puts "✅ Response parsed successfully!"
      puts "📋 Response structure:"
      parsed.each do |key, value|
        case value
        when Array
          puts "  #{key}: #{value.length} items"
        when String
          puts "  #{key}: #{value.length} characters"
        else
          puts "  #{key}: #{value.class}"
        end
      end
      
      puts "\n🎯 Sample Core Items:"
      Array(parsed["core_items"]).first(2).each_with_index do |item, index|
        puts "  #{index + 1}. #{item['item']}: #{item['description']}"
      end
      
      puts "\n📈 Sample Playstyle (Early):"
      puts "  #{parsed['playstyle_early']&.truncate(100)}"
      
      puts "\n🎉 AI Integration Test Completed Successfully!"
      
    rescue => e
      puts "❌ AI Integration Test Failed:"
      puts "   Error: #{e.class} - #{e.message}"
      puts "   Backtrace:"
      puts e.backtrace.first(5).map { |line| "     #{line}" }.join("\n")
    end
  end
  
  desc "Test AI service configuration"
  task check_config: :environment do
    puts "🚀 Checking Groq AI Service Configuration..."
    
    api_key = ENV['GROQ_API_KEY']
    if api_key.present?
      puts "✅ GROQ_API_KEY is configured"
      puts "   Length: #{api_key.length} characters"
      puts "   Starts with: #{api_key[0..10]}..."
    else
      puts "❌ GROQ_API_KEY is not configured"
      puts "   Please add GROQ_API_KEY to your .env file"
      puts "   Get your free API key at: https://console.groq.com/keys"
    end
    
    groq_model = ENV['GROQ_MODEL'] || 'llama3-70b-8192'
    puts "🤖 Selected Model: #{groq_model}"
    
    case groq_model
    when 'llama3-8b-8192'
      puts "   ⚡ Fastest model - great for development"
    when 'llama3-70b-8192'
      puts "   🧠 Most capable model - best for production"
    when 'mixtral-8x7b-32768'
      puts "   🔥 Balanced model with large context window"
    when 'gemma-7b-it'
      puts "   🔄 Alternative model option"
    end
    
    riot_key = ENV['RIOT_API_KEY']
    if riot_key.present?
      puts "✅ RIOT_API_KEY is configured"
    else
      puts "❌ RIOT_API_KEY is not configured"
    end
    
    puts "\n📋 Current Configuration:"
    puts "   Rails Environment: #{Rails.env}"
    puts "   AI Model: #{Rails.application.config.ai_model rescue 'Not configured'}"
    puts "   Application Name: #{Rails.application.class.module_parent_name}"
    puts "   Groq Endpoint: https://api.groq.com/openai/v1/chat/completions"
  end
  
  desc "Generate a sample build"
  task sample_build: :environment do
    puts "🎮 Generating Sample Build for Jinx vs Caitlyn matchup..."
    
    matchup = Matchup.create!(
      user_champion: "Jinx",
      user_role: "ADC", 
      ally_team: [{ champion: "Malphite", role: "TOP" }],
      enemy_team: [{ champion: "Caitlyn", role: "ADC" }]
    )
    
    prompt = PromptBuilder.new(matchup).generate
    response = AiClient.call(prompt)
    parsed = JSON.parse(response)
    
    matchup.update!(
      ai_response: response,
      runes: parsed["runes"],
      core_items: parsed["core_items"],
      situational_items: parsed["situational_items"],
      playstyle_early: parsed["playstyle_early"],
      playstyle_midgame: parsed["playstyle_mid"] || parsed["playstyle_midgame"],
      playstyle_lategame: parsed["playstyle_late"] || parsed["playstyle_lategame"],
      summary: parsed["summary"]
    )
    
    puts "✅ Sample matchup created with ID: #{matchup.id}"
    puts "🔗 View at: http://localhost:3000/matchups/#{matchup.id}"
    puts "🎯 Summary: #{matchup.summary}"
  end
end