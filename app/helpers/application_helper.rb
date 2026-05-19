module ApplicationHelper
  def nav_link(text, path, options = {})
    base_class = options.delete(:class) || "nav-item"
    is_active = current_page?(path)
    
    link_to path, **options, class: "#{base_class} #{is_active ? 'active' : ''}" do
      text
    end
  end

  def status_badge(status)
    colors = {
      "active" => "bg-[var(--color-success)]/20 text-[var(--color-success)]",
      "paused" => "bg-[var(--color-warning)]/20 text-[var(--color-warning)]",
      "archived" => "bg-[var(--color-text-muted)]/20 text-[var(--color-text-muted)]",
      "planning" => "bg-[var(--color-primary)]/20 text-[var(--color-primary)]"
    }
    
    content_tag :span, status&.capitalize || "Unknown",
                class: "px-2.5 py-0.5 rounded-full text-xs font-medium #{colors[status] || 'bg-[var(--color-surface-alt)] text-[var(--color-text-muted)]'}"
  end

  def project_type_icon(type)
    type&.icon || "📁"
  end

  def theme_card_preview(theme)
    colors = theme.colors
    content_tag :div, class: "w-full h-16 rounded-lg overflow-hidden flex" do
      safe_join([
        content_tag(:div, "", class: "flex-1", style: "background: #{colors['background']}"),
        content_tag(:div, "", class: "flex-1", style: "background: #{colors['surface']}"),
        content_tag(:div, "", class: "flex-1", style: "background: #{colors['primary']}"),
        content_tag(:div, "", class: "flex-1", style: "background: #{colors['secondary']}"),
        content_tag(:div, "", class: "flex-1", style: "background: #{colors['accent']}")
      ])
    end
  end

  def format_date(date)
    date&.strftime("%b %d, %Y")
  end

  def format_datetime(datetime)
    datetime&.strftime("%b %d, %Y at %I:%M %p")
  end

  def time_ago(timestamp)
    return "" unless timestamp
    seconds = Time.current - timestamp
    case seconds
    when 0..60 then "just now"
    when 61..3600 then "#{(seconds / 60).round}m ago"
    when 3601..86400 then "#{(seconds / 3600).round}h ago"
    when 86401..604800 then "#{(seconds / 86400).round}d ago"
    else format_date(timestamp.to_date)
    end
  end

  def category_icon(category)
    icons = {
      cli_agents: "💻",
      agent_frameworks: "🧠",
      local_inference: "🏠",
      mcp_protocol: "🔗",
      game_engine: "🎮",
      custom: "⚙️"
    }
    icons[category] || "📦"
  end

  def health_status_icon(status)
    case status
    when "connected" then "🟢"
    when "disconnected" then "🔴"
    when "error" then "🟡"
    else "⚪"
    end
  end

  def health_status_class(status)
    case status
    when "connected" then "text-[var(--color-success)]"
    when "disconnected" then "text-[var(--color-error)]"
    when "error" then "text-[var(--color-warning)]"
    else "text-[var(--color-text-muted)]"
    end
  end
end
