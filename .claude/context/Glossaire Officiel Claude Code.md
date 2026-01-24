Glossaire Officiel Claude Code
Voici la clarification officielle de chaque terme, avec sources.

1. SKILLS ✅ Feature Officielle
Définition : Templates de prompts réutilisables avec config YAML + instructions Markdown.

Stockage : .claude/skills/<nom>/SKILL.md

Fonctionnement :

Invoqués manuellement (/skill-name) ou automatiquement par Claude
Injectent leur contenu dans la conversation quand pertinents
Peuvent forker un contexte isolé (context: fork)
📚 Source : code.claude.com/docs/en/skills.md

2. SLASH COMMANDS ✅ Toujours Supporté (Skills recommandés pour nouveaux)
Statut : `.claude/commands/` toujours fonctionnel, mais Skills recommandés pour nouvelles créations.

**Ce que dit la doc officielle :**
> "Custom slash commands have been merged into skills. A file at .claude/commands/review.md and a skill at .claude/skills/review/SKILL.md both create /review and work the same way. Your existing .claude/commands/ files keep working."

**Différence concrète :**

| `.claude/commands/` | `.claude/skills/` |
|---------------------|-------------------|
| Fichier simple `.md` | Dossier avec `SKILL.md` |
| Fonctionne | Fonctionne + features en plus |
| Pas de frontmatter avancé | `context: fork`, `allowed-tools`, etc. |
| Invocation manuelle `/cmd` | Invocation manuelle + auto par Claude |

**En pratique :**
- Commands existants → gardent leur fonctionnement, aucune migration requise
- Nouvelles créations → skills recommandés car plus de possibilités
- Pas d'urgence à migrer quoi que ce soit

📚 Source : code.claude.com/docs/en/skills.md

3. SUBAGENTS ✅ Feature Officielle
Définition : Agents spécialisés avec contexte isolé, outils spécifiques, et permissions propres.

Stockage : .claude/agents/<nom>.md

Fonctionnement :

Claude délègue automatiquement selon la description du subagent
Chaque subagent a sa propre fenêtre de contexte (mémoire fraîche)
Ne peuvent PAS spawner d'autres subagents (pas de récursion infinie)
Subagents built-in : Explore, Plan, general-purpose

📚 Source : code.claude.com/docs/en/sub-agents.md

4. HOOKS ✅ Feature Officielle
Définition : Scripts shell/Python exécutés à des moments précis du cycle de vie.

Config : .claude/settings.json ou commande /hooks

Events disponibles :

PreToolUse, PostToolUse — avant/après utilisation d'outil
UserPromptSubmit — à la soumission d'un prompt
SessionStart, SessionEnd — début/fin de session
etc.
📚 Source : code.claude.com/docs/en/hooks.md

5. TASK TOOL ⚠️ Claude Agent SDK (pas Claude Code)
Important : Le Task tool que tu vois dans mes outils vient du Claude Agent SDK — c'est l'API pour construire des applications multi-agents.

Différence :

Claude Code	Agent SDK
Subagents via .claude/agents/	Task tool programmatique
Config déclarative	Code Python/TypeScript
Pour utilisateurs CLI	Pour développeurs d'apps
📚 Source : docs.anthropic.com/en/docs/agents-and-tools/claude-agent-sdk

6. WORKFLOWS ❌ PAS une feature officielle
Statut : Terme générique, pas un objet technique.

Dans la doc officielle : "Common workflows" = guides de bonnes pratiques (debug, PR, refactor...)

Ce que décrit Melvyn (APEX) : Un pattern user-built — orchestration custom avec :

Script bash qui séquence
Fichiers markdown injectés un par un
Boucle action → résultat → correction
Ce n'est pas natif — c'est une architecture que tu construis toi-même avec les features officielles (skills, hooks, subagents).

📚 Source : code.claude.com/docs/en/common-workflows.md

Tableau Récapitulatif
Terme	Officiel ?	C'est quoi	Stockage
Skill	✅ Oui	Prompt réutilisable	.claude/skills/
Slash Command	⚠️ Déprécié	Alias de skill	.claude/commands/
Subagent	✅ Oui	Agent contexte isolé	.claude/agents/
Hook	✅ Oui	Script lifecycle	.claude/settings.json
Task Tool	✅ SDK	API multi-agent	Code programmatique
Workflow	❌ Non	Pattern/guide	Documentation
Custom Agent	❌ Non	= Subagent custom	.claude/agents/
Ressources Officielles
Ressource	URL
Documentation principale	code.claude.com/docs
GitHub Claude Code	github.com/anthropics/claude-code
Agent SDK	docs.anthropic.com/en/docs/agents-and-tools/claude-agent-sdk
MCP Protocol	modelcontextprotocol.io
Anthropic Cookbook	github.com/anthropics/anthropic-cookbook
En Résumé
L'approche APEX/Melvyn = architecture custom construite avec :

Skills (les prompts injectés)
Hooks (déclenchement automatique)
Script orchestrateur (bash/python custom, pas natif)
C'est une bonne pratique, pas une feature. Claude Code fournit les briques (skills, subagents, hooks), toi tu construis le workflow.