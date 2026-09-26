# Mechanical Cursor -> Claude Code rewrites for upstream pstack files.
# Semantic translations (tools, cloud workers, /loop) live in AGENTS.md.
# Order matters: specific patterns first.

# Model config file
s#~/\.cursor/rules/pstack-models\.mdc#~/.claude/cstack-models.md#g
s#pstack-models\.mdc#cstack-models.md#g

# Skill and plugin paths
s#~/\.cursor/skills/#~/.claude/skills/#g
s#\.cursor/skills/#.claude/skills/#g
s#~/\.cursor/plugins/#~/.claude/plugins/#g

# Setup skill is replaced by setup-cstack
s#setup-pstack#setup-cstack#g

# Subagent types
s#subagent_type: "poteto-agent"#subagent_type: "cstack:poteto-agent"#g
s#subagent_type: "Comment Sicko"#subagent_type: "cstack:comment-sicko"#g
s#generalPurpose#general-purpose#g

# Question tool
s#AskQuestion#AskUserQuestion#g

# /loop is also a Claude Code command
s#Cursor's `/loop` command#Claude Code's `/loop` command#g

# Model slugs. Panels first, so each panel keeps three different tiers.
s#claude-opus-5-5-max, gpt-5\.6-sol-max, grok-4\.7-xhigh-fast#opus, sonnet, haiku#g
s#`claude-opus-5-5-max`, `gpt-5\.6-sol-max`, `grok-4\.7-xhigh-fast`#`opus`, `sonnet`, `haiku`#g
s#`claude-opus-5-5-max`, `gpt-5\.6-sol-max`, and `grok-4\.7-xhigh-fast`#`opus`, `sonnet`, and `haiku`#g
s#claude-opus-5-5-max#opus#g
s#claude-opus-5-5-medium#opus#g
s#gpt-5\.6-sol-max#opus#g
s#grok-4\.7-xhigh-fast#sonnet#g
s#grok-4\.7-medium-fast#sonnet#g
