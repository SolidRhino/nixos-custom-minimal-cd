# Code Style & Conventions

## Nix Language Style

### General Principles
- **Declarative**: Describe what you want, not how to build it
- **Functional**: Pure functions without side effects where possible
- **Immutable**: Data structures are immutable by default

### Naming Conventions
- **Variables**: camelCase (e.g., `systemPackages`, `hostPlatform`)
- **Attributes**: kebab-case in attrsets (e.g., `nix-command`, `flake-parts`)
- **Files**: kebab-case with `.nix` extension (e.g., `helix.nix`, `neovim.nix`)
- **Directories**: kebab-case (e.g., `flake-parts`, `editors`)

### Formatting
- **Indentation**: 2 spaces (standard Nix convention)
- **Line Length**: Keep reasonable (80-100 chars when practical)
- **String Literals**: Use `''` for multi-line strings, `"` for single-line
- **Lists**: Line breaks for readability when lists are long

### Example Style
```nix
{ config, pkgs, lib, ... }:

{
  # Imports at the top
  imports = [
    ./editors/helix.nix
    ./editors/neovim.nix
  ];

  # Configuration grouped logically
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Package lists with proper alignment
  environment.systemPackages = with pkgs; [
    git
    # Comments for non-obvious choices
  ];

  # Services configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
}
```

## Project-Specific Patterns

### Module Organization
- **Separation of Concerns**: Each editor gets its own module file
- **Modular Imports**: Use `imports = [ ... ]` to compose configurations
- **Flake-Parts Structure**: Organize outputs in `flake-parts/` directory

### Override Patterns
- **Use `lib.mkForce`**: When overriding base module settings explicitly
  ```nix
  initialHashedPassword = lib.mkForce null;
  image.fileName = lib.mkForce "custom-name.iso";
  ```
- **Use `lib.mkDefault`**: For defaults that can be easily overridden
  ```nix
  networking.useDHCP = lib.mkDefault true;
  ```

### Flake-Parts Conventions
- **`perSystem` Function**: Used for per-system outputs (packages, apps)
- **`mkIso` Helper**: Standardized ISO builder function in `flake-parts/iso.nix`
- **System List**: Define supported architectures in flake root
  ```nix
  systems = [ "x86_64-linux" "aarch64-linux" ];
  ```

## File Organization

### Directory Structure
```
custom-minimal-cd/
├── flake.nix              # Entry point, imports flake-parts
├── flake.lock             # Auto-generated, track in git
├── configuration.nix      # System configuration
├── flake-parts/           # Modular flake components
│   └── iso.nix           # ISO builder logic
├── editors/               # Editor-specific modules
│   ├── helix.nix
│   └── neovim.nix
└── .github/workflows/     # CI/CD automation
    └── build-iso.yml
```

### Commit Conventions
- **Feature additions**: `feat: add X`
- **Bug fixes**: `fix: resolve Y`
- **Documentation**: `docs: update Z`
- **Configuration changes**: `config: adjust W`
- **CI/CD changes**: `ci: modify V`

### Commit Message Rules
**IMPORTANT**: Never add Claude Code attribution to git commits:
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```
This is explicitly forbidden per project policy.

## Documentation

### Inline Comments
- **When**: Explain non-obvious choices, overrides, or complex logic
- **How**: Short, clear comments above or inline with code
- **Example**:
  ```nix
  # Override base ISO's empty password hash for installer convenience
  initialHashedPassword = lib.mkForce null;
  ```

### README Updates
- Keep README.md synchronized with configuration changes
- Document new features, packages, or significant changes
- Include examples for common customizations