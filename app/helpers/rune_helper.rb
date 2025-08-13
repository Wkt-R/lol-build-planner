module RuneHelper
  def describe_rune_strategy(rune_data)
    primary = rune_data[:primary_tree]
    secondary = rune_data[:secondary_tree]
    keystone = rune_data[:keystone]
    
    strategy_descriptions = {
      ['precision', 'resolve'] => 'sustained damage with enhanced survivability',
      ['precision', 'domination'] => 'aggressive damage scaling with burst potential',
      ['precision', 'sorcery'] => 'consistent DPS with enhanced mobility and utility',
      ['precision', 'inspiration'] => 'adaptive playstyle with utility and scaling',
      
      ['domination', 'precision'] => 'high burst damage with sustained fight potential',
      ['domination', 'resolve'] => 'aggressive trades with defensive tools',
      ['domination', 'sorcery'] => 'maximum damage output with enhanced abilities',
      ['domination', 'inspiration'] => 'flexible assassination with creative utility',
      
      ['sorcery', 'precision'] => 'spell-based damage with auto-attack synergy',
      ['sorcery', 'domination'] => 'maximum ability damage and penetration',
      ['sorcery', 'resolve'] => 'sustained magic damage with defensive tools',
      ['sorcery', 'inspiration'] => 'utility-focused spellcasting with adaptability',
      
      ['resolve', 'precision'] => 'tank build with sustained damage threat',
      ['resolve', 'domination'] => 'durable frontline with engage potential',
      ['resolve', 'sorcery'] => 'magic resist tank with utility spells',
      ['resolve', 'inspiration'] => 'utility tank with team support tools',
      
      ['inspiration', 'precision'] => 'creative gameplay with scaling damage',
      ['inspiration', 'domination'] => 'unconventional strategies with burst',
      ['inspiration', 'sorcery'] => 'utility-first approach with spell enhancement',
      ['inspiration', 'resolve'] => 'support-oriented build with survivability'
    }
    
    base_strategy = strategy_descriptions[[primary, secondary]] || 'versatile gameplay with balanced strengths'
    
    keystone_details = case keystone
    when 'Conqueror'
      ', excelling in extended fights'
    when 'Press the Attack'
      ', focusing on burst combos'
    when 'Lethal Tempo'
      ', maximizing attack speed scaling'
    when 'Fleet Footwork'
      ', emphasizing sustain and mobility'
    when 'Electrocute'
      ', delivering powerful burst damage'
    when 'Predator'
      ', enabling strong roaming potential'
    when 'Dark Harvest'
      ', scaling damage with takedowns'
    when 'Hail of Blades'
      ', providing early game aggression'
    when 'Arcane Comet'
      ', enhancing poke damage'
    when 'Phase Rush'
      ', offering superior mobility'
    when 'Summon Aery'
      ', supporting trades and shields'
    when 'Grasp of the Undying'
      ', providing scaling tankiness'
    when 'Aftershock'
      ', delivering defensive team fight power'
    when 'Guardian'
      ', protecting allies in fights'
    when 'Glacial Augment'
      ', controlling enemy movement'
    when 'Unsealed Spellbook'
      ', adapting to game state'
    when 'First Strike'
      ', generating economic advantages'
    else
      ''
    end
    
    base_strategy + keystone_details + '.'
  end
  
  def rune_tree_color(tree_name)
    colors = {
      'precision' => '#c8aa3c',
      'domination' => '#dc143c', 
      'sorcery' => '#4169e1',
      'resolve' => '#228b22',
      'inspiration' => '#ffd700'
    }
    colors[tree_name.to_s.downcase] || '#c8aa3c'
  end
  
  def rune_tree_gradient(tree_name)
    gradients = {
      'precision' => 'linear-gradient(135deg, #c8aa3c 0%, #f0e6d2 100%)',
      'domination' => 'linear-gradient(135deg, #dc143c 0%, #ff6b6b 100%)',
      'sorcery' => 'linear-gradient(135deg, #4169e1 0%, #87ceeb 100%)',
      'resolve' => 'linear-gradient(135deg, #228b22 0%, #90ee90 100%)',
      'inspiration' => 'linear-gradient(135deg, #ffd700 0%, #ffffe0 100%)'
    }
    gradients[tree_name.to_s.downcase] || gradients['precision']
  end
end