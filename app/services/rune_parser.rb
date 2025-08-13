class RuneParser
  RUNE_TREES = {
    'precision' => {
      name: 'Precision',
      keystones: ['Conqueror', 'Press the Attack', 'Lethal Tempo', 'Fleet Footwork'],
      tiers: {
        tier1: ['Overheal', 'Triumph', 'Presence of Mind'],
        tier2: ['Legend: Alacrity', 'Legend: Tenacity', 'Legend: Bloodline'],
        tier3: ['Coup de Grace', 'Cut Down', 'Last Stand']
      }
    },
    'domination' => {
      name: 'Domination',
      keystones: ['Electrocute', 'Predator', 'Dark Harvest', 'Hail of Blades'],
      tiers: {
        tier1: ['Cheap Shot', 'Taste of Blood', 'Sudden Impact'],
        tier2: ['Zombie Ward', 'Ghost Poro', 'Eyeball Collection'],
        tier3: ['Treasure Hunter', 'Ingenious Hunter', 'Relentless Hunter', 'Ultimate Hunter']
      }
    },
    'sorcery' => {
      name: 'Sorcery',
      keystones: ['Summon Aery', 'Arcane Comet', 'Phase Rush'],
      tiers: {
        tier1: ['Nullifying Orb', 'Manaflow Band', 'Nimbus Cloak'],
        tier2: ['Transcendence', 'Celerity', 'Absolute Focus'],
        tier3: ['Scorch', 'Waterwalking', 'Gathering Storm']
      }
    },
    'resolve' => {
      name: 'Resolve',
      keystones: ['Grasp of the Undying', 'Aftershock', 'Guardian'],
      tiers: {
        tier1: ['Demolish', 'Font of Life', 'Shield Bash'],
        tier2: ['Conditioning', 'Second Wind', 'Bone Plating'],
        tier3: ['Overgrowth', 'Revitalize', 'Unflinching']
      }
    },
    'inspiration' => {
      name: 'Inspiration',
      keystones: ['Glacial Augment', 'Unsealed Spellbook', 'First Strike'],
      tiers: {
        tier1: ['Hextech Flashtraption', 'Magical Footwear', 'Perfect Timing'],
        tier2: ['Future\'s Market', 'Minion Dematerializer', 'Biscuit Delivery'],
        tier3: ['Cosmic Insight', 'Approach Velocity', 'Time Warp Tonic']
      }
    }
  }.freeze

  RUNE_ICONS = {
    # Precision
    'Conqueror' => '⚔️',
    'Press the Attack' => '🎯',
    'Lethal Tempo' => '⚡',
    'Fleet Footwork' => '👟',
    'Overheal' => '💚',
    'Triumph' => '🏆',
    'Presence of Mind' => '🧠',
    'Legend: Alacrity' => '⚡',
    'Legend: Tenacity' => '🛡️',
    'Legend: Bloodline' => '🩸',
    'Coup de Grace' => '💥',
    'Cut Down' => '⚔️',
    'Last Stand' => '⚰️',

    # Domination
    'Electrocute' => '⚡',
    'Predator' => '🐺',
    'Dark Harvest' => '💀',
    'Hail of Blades' => '⚔️',
    'Cheap Shot' => '🗡️',
    'Taste of Blood' => '🩸',
    'Sudden Impact' => '💥',
    'Zombie Ward' => '👁️',
    'Ghost Poro' => '👻',
    'Eyeball Collection' => '👁️',
    'Treasure Hunter' => '💎',
    'Ingenious Hunter' => '🔧',
    'Relentless Hunter' => '🏃',
    'Ultimate Hunter' => '🌟',

    # Sorcery
    'Summon Aery' => '🧚',
    'Arcane Comet' => '☄️',
    'Phase Rush' => '💨',
    'Nullifying Orb' => '🛡️',
    'Manaflow Band' => '💙',
    'Nimbus Cloak' => '☁️',
    'Transcendence' => '📈',
    'Celerity' => '🏃',
    'Absolute Focus' => '🎯',
    'Scorch' => '🔥',
    'Waterwalking' => '🌊',
    'Gathering Storm' => '⛈️',

    # Resolve
    'Grasp of the Undying' => '👊',
    'Aftershock' => '💥',
    'Guardian' => '🛡️',
    'Demolish' => '🏗️',
    'Font of Life' => '💧',
    'Shield Bash' => '🛡️',
    'Conditioning' => '💪',
    'Second Wind' => '💨',
    'Bone Plating' => '🦴',
    'Overgrowth' => '🌱',
    'Revitalize' => '💖',
    'Unflinching' => '⚖️',

    # Inspiration
    'Glacial Augment' => '❄️',
    'Unsealed Spellbook' => '📖',
    'First Strike' => '💰',
    'Hextech Flashtraption' => '⚡',
    'Magical Footwear' => '👢',
    'Perfect Timing' => '⏰',
    'Future\'s Market' => '💳',
    'Minion Dematerializer' => '👻',
    'Biscuit Delivery' => '🍪',
    'Cosmic Insight' => '🌌',
    'Approach Velocity' => '🏃',
    'Time Warp Tonic' => '⏳'
  }.freeze

  def self.parse(rune_text)
    new(rune_text).parse
  end

  def initialize(rune_text)
    @rune_text = rune_text.to_s
  end

  def parse
    return default_runes if @rune_text.blank?

    primary_tree, secondary_tree = extract_trees
    runes = extract_runes

    {
      primary_tree: primary_tree,
      secondary_tree: secondary_tree,
      keystone: find_keystone(runes),
      primary_runes: find_tree_runes(primary_tree, runes),
      secondary_runes: find_tree_runes(secondary_tree, runes, 2), # Only 2 runes for secondary
      stat_shards: extract_stat_shards,
      raw_text: @rune_text
    }
  end

  private

  def extract_trees
    primary = nil
    secondary = nil

    # Look for patterns like "Primary: Precision" or "Precision tree"
    RUNE_TREES.each do |key, data|
      tree_name = data[:name]
      if @rune_text.match?(/primary[:\s]*#{tree_name}/i)
        primary = key
      elsif @rune_text.match?(/secondary[:\s]*#{tree_name}/i)
        secondary = key
      elsif primary.nil? && @rune_text.match?(/#{tree_name}/i)
        primary = key
      elsif primary && primary != key && @rune_text.match?(/#{tree_name}/i)
        secondary = key
      end
    end

    [primary || 'precision', secondary || 'resolve']
  end

  def extract_runes
    runes = []
    
    # Extract all rune names from the text
    RUNE_ICONS.keys.each do |rune_name|
      if @rune_text.match?(/#{Regexp.escape(rune_name)}/i)
        runes << rune_name
      end
    end

    runes
  end

  def find_keystone(runes)
    # Find the first keystone mentioned
    all_keystones = RUNE_TREES.values.flat_map { |tree| tree[:keystones] }
    runes.find { |rune| all_keystones.include?(rune) } || 'Conqueror'
  end

  def find_tree_runes(tree_key, runes, limit = 3)
    return [] unless RUNE_TREES[tree_key]

    tree_runes = RUNE_TREES[tree_key][:tiers].values.flatten
    selected = runes.select { |rune| tree_runes.include?(rune) }
    
    # If we don't have enough, fill with defaults
    while selected.length < limit
      RUNE_TREES[tree_key][:tiers].each_value do |tier_runes|
        missing_rune = tier_runes.find { |r| !selected.include?(r) }
        if missing_rune
          selected << missing_rune
          break
        end
      end
      break if selected.length >= limit
    end

    selected.first(limit)
  end

  def extract_stat_shards
    # Default stat shards - could be enhanced to parse from text
    {
      offense: 'Adaptive Force',
      flex: 'Adaptive Force', 
      defense: 'Health'
    }
  end

  def default_runes
    {
      primary_tree: 'precision',
      secondary_tree: 'resolve',
      keystone: 'Conqueror',
      primary_runes: ['Triumph', 'Legend: Alacrity', 'Last Stand'],
      secondary_runes: ['Bone Plating', 'Overgrowth'],
      stat_shards: {
        offense: 'Adaptive Force',
        flex: 'Adaptive Force',
        defense: 'Health'
      },
      raw_text: 'Default runes - AI parsing failed'
    }
  end
end