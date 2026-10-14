# Mechanical rewrites for upstream pstack files.
#
# The skills are shared by every app cstack supports, so these rewrites stay
# app-neutral. They only rename the model file, the setup skill, and model
# slugs. Tool names, folder paths, and subagent types keep upstream's words;
# each app's adapter (adapters/<app>.md) translates them at run time.
# Order matters: specific patterns first.

# Model config file
s#~/\.cursor/rules/pstack-models\.mdc#~/.cstack/models.md#g
s#the `pstack-models\.mdc` rule#`~/.cstack/models.md`#g
s#pstack-models\.mdc#~/.cstack/models.md#g

# Setup skill is replaced by setup-cstack
s#setup-pstack#setup-cstack#g

# Model slugs become model tiers. AGENTS.md defines the tiers, and each
# adapter maps them to that app's models. The effort token in a slug
# (xhigh, max, medium) maps to the effort setting, not to a tier.
# Two-seat panels first.
s#`claude-opus-5-5-xhigh` and `grok-4\.7-xhigh-fast`#`strong` and `fast`#g
s#claude-opus-5-5-xhigh, grok-4\.7-xhigh-fast#strong, fast#g
s#claude-opus-5-5-(xhigh|max|medium)#strong#g
s#grok-4\.7-(xhigh|medium)-fast#fast#g
