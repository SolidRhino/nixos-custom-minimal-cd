# Serena Usage in This Project

## Memory Storage

Project memories are **stored in git** at `.serena/memories/`.

### Why Memories Are Committed

- **Persistence:** Memories survive across development sessions and machines
- **Collaboration:** Team members can benefit from documented project context
- **History:** Changes to project understanding are tracked in git history
- **Onboarding:** New contributors get instant project context

### Memory Files

The following memories are maintained:

1. **project_overview.md** - Project purpose, features, and use cases
2. **tech_stack.md** - Technologies, frameworks, and dependencies
3. **code_style_conventions.md** - Nix style guide and project patterns
4. **codebase_structure.md** - Directory layout and architectural patterns
5. **darwin_constraints.md** - macOS-specific limitations and workflows
6. **suggested_commands.md** - Development commands and workflows
7. **task_completion_checklist.md** - Quality gates for task completion
8. **serena_usage.md** - This file (meta-documentation)

### Cache Exclusion

The `.serena/cache/` directory is **excluded from git** via `.serena/.gitignore`:
```
/cache
```

This keeps temporary Serena data out of the repository while preserving important memories.

## Memory Maintenance

### When to Update Memories

- **After significant features:** Update codebase_structure.md
- **New patterns emerge:** Update code_style_conventions.md
- **Workflow changes:** Update suggested_commands.md
- **New constraints discovered:** Update darwin_constraints.md

### How to Update

Use Serena's memory tools:
```
mcp__serena__write_memory    # Create or overwrite
mcp__serena__edit_memory     # Modify with regex
mcp__serena__read_memory     # Review content
mcp__serena__list_memories   # See all memories
```

After updating memories with Serena tools, commit them:
```bash
git add .serena/memories/
git commit -m "docs: update Serena memories"
git push origin main
```

## Benefits for Future Sessions

When starting a new session, Serena automatically:
1. Activates the project
2. Loads memories from `.serena/memories/`
3. Provides instant context about:
   - What the project does
   - How it's structured
   - What patterns to follow
   - What commands to use

This eliminates the need to re-explain the project in every session.
