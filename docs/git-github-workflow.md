# Git and GitHub Workflow

## Overview

Git and GitHub are related, but they are not the same system.

**Git** is a distributed version-control system used to track changes to files and source code.

**GitHub** is an online collaboration platform that hosts Git repositories and adds features such as:

- Repository hosting
- Issues
- Pull requests
- Releases
- Discussions
- Forks
- Actions and automation
- Project documentation
- Collaboration

This guide explains the workflow used by the Windows 11 Cybersecurity Workstation project.

---

# 1. What Is a Repository?

A Git repository is a project directory whose history is tracked by Git.

For example:

```text
windows-cybersecurity-workstation/
├── README.md
├── SECURITY.md
├── docs/
├── examples/
├── scripts/
└── assets/
```

Once Git is initialized, the repository can track:

- New files
- Changed files
- Deleted files
- Who made a change
- When the change occurred
- Why the change was made
- Previous versions of the project

Git stores this history in a hidden:

```text
.git/
```

directory.

Do not manually modify the contents of `.git/` unless you understand the consequences.

---

# 2. Local Repository vs GitHub Repository

## Local Repository

Lives on the workstation.

Example:

```text
C:\Users\<USERNAME>\Cybersecurity\GitHub\windows-cybersecurity-workstation
```

Work can be performed locally without an Internet connection.

## Remote Repository

Lives on a Git hosting service such as GitHub.

Example conceptually:

```text
github.com/YOUR_GITHUB_USERNAME/windows-cybersecurity-workstation
```

The remote repository makes the project accessible to other users.

---

# 3. The Basic Git Workflow

The core Git workflow is:

```text
Edit
  ↓
Review
  ↓
Stage
  ↓
Commit
  ↓
Push
```

Each stage serves a different purpose.

---

# 4. Check Repository Status

Run:

```powershell
git status
```

Git reports files that are:

- Untracked
- Modified
- Staged
- Deleted

Run this frequently.

It is one of the most useful Git commands.

---

# 5. The Working Tree

The files currently being edited are called the **working tree**.

Suppose:

```text
README.md
```

is changed.

Git recognizes that the file differs from the last committed version.

It does not automatically include that change in the next commit.

---

# 6. Review Changes

Before staging a file, review the modifications:

```powershell
git diff
```

This shows changes in the working tree that have not yet been staged.

For a security-focused repository, this review step is particularly important.

Look for:

- Credentials
- Usernames
- Email addresses
- Private IP information
- Tokens
- Recovery information
- Accidental debug output
- Unsanitized screenshots

---

# 7. Stage Files

Staging tells Git which changes should be part of the next commit.

Stage one file:

```powershell
git add README.md
```

Stage several files:

```powershell
git add README.md SECURITY.md
```

Stage all currently intended changes:

```powershell
git add .
```

Use:

```powershell
git add .
```

carefully.

Always review:

```powershell
git status
```

after staging.

---

# 8. Review Staged Changes

Before creating the commit:

```powershell
git diff --cached
```

This displays exactly what is currently staged for the next commit.

For this project, this is a mandatory safety step before public publication.

---

# 9. Create a Commit

A commit records a point in the project's history.

Example:

```powershell
git commit -m "Add Windows security baseline"
```

A useful commit message describes the change.

Good examples:

```text
Add Windows security baseline
Add development tool installer
Document GitHub SSH workflow
Fix WinGet package detection
Add repository sanitization guidance
```

Poor examples:

```text
stuff
update
changes
fix
```

A commit should communicate intent.

---

# 10. View Commit History

Run:

```powershell
git log --oneline
```

Example:

```text
a14c202 Add development environment guide
1f82b11 Add security baseline scanner
4a98d15 Initial repository structure
```

Each commit has a unique identifier.

Git history provides traceability and allows earlier versions to be examined.

---

# 11. Branches

A branch is an independent line of development.

The primary branch for this project is:

```text
main
```

Check the current branch:

```powershell
git branch --show-current
```

Create a feature branch:

```powershell
git switch -c feature/example
```

Return to `main`:

```powershell
git switch main
```

Branches allow work to be developed without immediately changing the stable main branch.

---

# 12. What Is a Remote?

A remote is a reference to another copy of the Git repository.

For GitHub, the primary remote is conventionally named:

```text
origin
```

Check remotes:

```powershell
git remote -v
```

Example:

```text
origin  git@github.com:YOUR_GITHUB_USERNAME/windows-cybersecurity-workstation.git
```

---

# 13. Push

A push uploads local commits to the remote GitHub repository.

Example:

```powershell
git push
```

For the first push of a new branch:

```powershell
git push -u origin main
```

The `-u` option establishes the upstream relationship so future pushes can usually use:

```powershell
git push
```

---

# 14. Pull

A pull retrieves changes from the remote repository and integrates them locally.

```powershell
git pull
```

Before beginning work on a repository that may have been changed elsewhere, pulling first can prevent unnecessary conflicts.

---

# 15. Fetch

Fetch retrieves remote Git information without immediately merging it:

```powershell
git fetch
```

This is useful when you want to inspect remote changes before integrating them.

---

# 16. Clone

Cloning downloads a complete Git repository.

Example using SSH:

```powershell
git clone git@github.com:YOUR_GITHUB_USERNAME/REPOSITORY.git
```

A clone includes:

- Project files
- Git history
- Branch information
- Remote configuration

This is how another user can obtain this project.

---

# 17. How This Repository Helps Other Users

A public repository can provide:

## Documentation

Users can read:

```text
README.md
docs/
```

without installing anything.

## Commands

Users can copy individual commands from:

```text
docs/
examples/
```

## Scripts

Users can inspect and run:

```text
scripts/
examples/powershell/
```

## Version Information

Users can compare their environment against:

```text
docs/tool-manifest.md
```

## Troubleshooting

Known problems and solutions can be documented rather than repeatedly rediscovered.

## Collaboration

Users can suggest improvements through GitHub.

---

# 18. Issues

GitHub Issues can be used to report:

- Bugs
- Documentation problems
- Compatibility problems
- Feature requests
- Installation failures

An issue is not automatically a security-reporting channel.

Sensitive vulnerabilities or accidentally exposed credentials should follow the repository's:

```text
SECURITY.md
```

guidance.

---

# 19. Forks

A fork creates a copy of someone else's GitHub repository under another GitHub account.

A user might fork this project to:

- Modify the workstation design
- Add different tools
- Support another Windows version
- Build organization-specific configuration
- Experiment without changing the original project

---

# 20. Pull Requests

A Pull Request (PR) proposes changes from one branch or fork into another.

A typical community contribution workflow is:

```text
Fork repository
      ↓
Clone fork
      ↓
Create branch
      ↓
Make changes
      ↓
Commit
      ↓
Push
      ↓
Open pull request
      ↓
Project owner reviews changes
```

The repository owner can:

- Approve
- Request changes
- Discuss
- Reject
- Merge

the contribution.

---

# 21. GitHub CLI

GitHub CLI provides command-line access to GitHub functionality.

Verify authentication:

```powershell
gh auth status
```

Useful examples:

```powershell
gh repo view
```

```powershell
gh issue list
```

```powershell
gh pr list
```

GitHub CLI complements Git.

It does not replace Git.

---

# 22. Repository Safety Workflow

For this project, use the following sequence before every public commit:

```text
1. Edit files
2. Save files
3. git status
4. git diff
5. Run repository safety checks
6. Stage intended files
7. git status
8. git diff --cached
9. Commit
10. Review commit
11. Push
```

This sequence helps prevent accidental publication of sensitive data.

---

# 23. Never Commit Secrets

Do not commit:

- Passwords
- SSH private keys
- API tokens
- Access tokens
- BitLocker recovery keys
- Recovery codes
- `.env` files containing credentials
- Session cookies
- Private packet captures
- Unsanitized forensic evidence
- Personally identifying screenshots

See:

[Repository Sanitization Guide](sanitization-guide.md)

---

# 24. Undoing an Unstaged Change

To discard an unstaged change to a tracked file:

```powershell
git restore FILE
```

Example:

```powershell
git restore README.md
```

Use this carefully.

The uncommitted modification will be discarded.

---

# 25. Unstage a File

If a file was accidentally staged:

```powershell
git restore --staged FILE
```

Example:

```powershell
git restore --staged README.md
```

The file remains on disk but is removed from the staging area.

---

# 26. Do Not Assume Deleting a Secret Solves Exposure

Git retains history.

If a credential is committed:

1. Revoke or rotate the credential.
2. Determine whether it was pushed to GitHub.
3. Stop further publication.
4. Remove sensitive material from Git history when necessary.
5. Re-scan the repository.

Deleting the visible file does not automatically remove previous commits.

---

# 27. Example Daily Workflow

Start work:

```powershell
git status
```

Update from GitHub when appropriate:

```powershell
git pull
```

Edit files.

Review:

```powershell
git diff
```

Stage:

```powershell
git add docs/example.md
```

Review:

```powershell
git diff --cached
```

Commit:

```powershell
git commit -m "Add example documentation"
```

Push:

```powershell
git push
```

---

# 28. Why Git History Matters

Git history provides:

- Accountability
- Reproducibility
- Troubleshooting
- Change tracking
- Documentation of technical decisions
- Recovery from mistakes
- Evidence of project development

For a technical portfolio, a clean commit history can also demonstrate how a project evolved rather than presenting only the finished product.

---

# 29. GitHub Portfolio Value

A well-maintained cybersecurity repository can demonstrate:

- Technical writing
- PowerShell development
- Security engineering
- Configuration management
- Troubleshooting
- Version control
- Documentation discipline
- Secure-development practices
- Testing methodology

The value comes from the quality of the work, not simply the number of repositories.

---

## Core Concept

> Git records how the project changes. GitHub makes that project accessible, collaborative, and discoverable.