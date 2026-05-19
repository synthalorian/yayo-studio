# Seed system themes
puts "Seeding system themes..."
Theme.seed_system_themes!

# Seed default project types
puts "Seeding project types..."
project_types = [
  { name: "Game", icon: "🎮", color: "#b388ff", description: "Video game development projects", position: 1 },
  { name: "Music", icon: "🎵", color: "#ff6ec7", description: "Music production, composition, and audio", position: 2 },
  { name: "Code", icon: "💻", color: "#00e5ff", description: "Software development and libraries", position: 3 },
  { name: "Writing", icon: "✍️", color: "#ffd700", description: "Creative writing, docs, and notes", position: 4 },
  { name: "Art", icon: "🎨", color: "#ff5722", description: "Visual art, design, and illustrations", position: 5 },
  { name: "Design", icon: "🎯", color: "#4fc3f7", description: "UI/UX design and mockups", position: 6 },
  { name: "System", icon: "🔧", color: "#8bc34a", description: "System administration and infrastructure", position: 7 },
  { name: "Video", icon: "🎬", color: "#e53935", description: "Video production and editing", position: 8 },
  { name: "AI", icon: "🤖", color: "#00e676", description: "AI/ML experiments and integrations", position: 9 },
  { name: "Other", icon: "📁", color: "#78909c", description: "Miscellaneous projects", position: 10 }
]

project_types.each do |attrs|
  ProjectType.find_or_create_by!(name: attrs[:name]) do |pt|
    pt.assign_attributes(attrs)
  end
end

# Create a demo user if none exists
unless User.exists?
  puts "Creating demo user..."
  user = User.create!(
    email: "synth@yayo.studio",
    name: "Synth",
    password: "yayo_studio",
    theme_name: "synthwave-84"
  )

  # Create demo projects
  puts "Creating demo projects..."
  projects = {
    "Holy Lands" => { type: "Game", status: "active", description: "Unity/C# RPG with deep lore systems" },
    "Synthocalypse" => { type: "Game", status: "active", description: "Unreal Engine/C++ post-apocalyptic synthwave world" },
    "Blood Legacy" => { type: "Game", status: "active", description: "Godot/GDScript dark fantasy narrative game" },
    "Open Habit" => { type: "Code", status: "active", description: "Retro-synthwave habit tracking app" },
    "Yayo Studio" => { type: "Code", status: "active", description: "The project hub itself — meta!" },
    "Praise Team" => { type: "Music", status: "active", description: "Church praise team guitar + vocals" },
    "Omarchy" => { type: "System", status: "active", description: "Arch/Hyprland Linux personal distro" }
  }

  projects.each do |name, attrs|
    type = ProjectType.find_by(name: attrs[:type])
    user.projects.create!(
      name: name,
      description: attrs[:description],
      status: attrs[:status],
      project_type: type
    )
  end

  puts "Seeding complete!"
  puts "  - #{Theme.count} themes"
  puts "  - #{ProjectType.count} project types"
  puts "  - #{User.count} users"
  puts "  - #{Project.count} projects"
  puts ""
  puts "Login: synth@yayo.studio / yayo_studio"
end

# Seed demo AI harness connections from auto-discovery
puts "Seeding AI harness connections..."
harness_project = Project.find_by(name: "Yayo Studio")
if harness_project && harness_project.ai_integrations.empty?
  discovered = HarnessRegistry.auto_discover!

  discovered.first(4).each do |entry|
    harness_def = HarnessRegistry.find(entry[:harness])
    next unless harness_def

    harness_project.ai_integrations.create(
      name: harness_def.name,
      provider: entry[:harness].split("-").first,
      harness_type: entry[:harness],
      status: "connected",
      enabled: true,
      config: {
        "cli_path" => entry[:path],
        "version" => entry[:version],
        "auto_discovered" => true
      }
    )
    puts "  ✓ #{harness_def.name}"
  end
end
