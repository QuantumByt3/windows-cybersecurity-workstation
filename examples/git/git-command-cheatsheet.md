# Git Command Cheat Sheet

A concise reference for the Git workflow used by the **Windows 11 Cybersecurity Workstation** project.

> Review commands before running them. Some Git operations can discard local work.

---

## Repository Status

Show the current repository state:

```powershell
git status
```

Show the current branch:

```powershell
git branch --show-current
```

Show configured remotes:

```powershell
git remote -v
```

---

## Review Changes

Show unstaged changes:

```powershell
git diff
```

Show staged changes:

```powershell
git diff --cached
```

Show recent commits:

```powershell
git log --oneline --decorate -10
```

---

## Stage Changes

Stage one file:

```powershell
git add FILE
```

Example:

```powershell
git add README.md
```

Stage several files:

```powershell
git add README.md SECURITY.md
```

Stage all intended changes in the current repository:

```powershell
git add .
```

Always follow with:

```powershell
git status
```

---

## Commit Changes

Create a commit:

```powershell
git commit -m "Describe the change"
```

Examples:

```text
Add Windows security baseline
Add development environment guide
Fix WinGet package detection
Add repository safety checks
```

---

## Branches

List branches:

```powershell
git branch
```

Create and switch to a branch:

```powershell
git switch -c feature/example
```

Switch back to main:

```powershell
git switch main
```

Delete a local branch after it is no longer needed:

```powershell
git branch -d feature/example
```

---

## Remote Synchronization

Retrieve remote metadata without merging:

```powershell
git fetch
```

Pull remote changes:

```powershell
git pull
```

Push current branch:

```powershell
git push
```

First push of `main`:

```powershell
git push -u origin main
```

---

## Clone a Repository

Using SSH:

```powershell
git clone git@github.com:YOUR_GITHUB_USERNAME/REPOSITORY.git
```

Using HTTPS:

```powershell
git clone https://github.com/YOUR_GITHUB_USERNAME/REPOSITORY.git
```

For this workstation, SSH is the preferred Git authentication workflow.

---

## Initialize a New Repository

Inside an existing project directory:

```powershell
git init
```

Verify the branch:

```powershell
git branch --show-current
```

If necessary:

```powershell
git branch -M main
```

Do not initialize a public-facing repository until `.gitignore` and sanitization controls have been reviewed.

---

## Add a GitHub Remote

Example SSH remote:

```powershell
git remote add origin git@github.com:YOUR_GITHUB_USERNAME/REPOSITORY.git
```

Verify:

```powershell
git remote -v
```

---

## Undo an Unstaged Change

Discard local modifications to a tracked file:

```powershell
git restore FILE
```

Example:

```powershell
git restore README.md
```

**Warning:** This discards the unstaged modification.

---

## Unstage a File

Remove a file from the staging area while keeping its local changes:

```powershell
git restore --staged FILE
```

Example:

```powershell
git restore --staged README.md
```

---

## Inspect a Commit

Show one commit:

```powershell
git show COMMIT
```

Example:

```powershell
git show a14c202
```

---

## Compare Branches

```powershell
git diff main..feature/example
```

---

## Git Identity

View global Git settings:

```powershell
git config --global --list
```

Set username:

```powershell
git config --global user.name "YOUR_GITHUB_USERNAME"
```

Set email:

```powershell
git config --global user.email "YOUR_GITHUB_NOREPLY_EMAIL"
```

Set default branch:

```powershell
git config --global init.defaultBranch main
```

---

## GitHub SSH

Test GitHub authentication:

```powershell
ssh -T git@github.com
```

A successful result should indicate authentication succeeded while also stating that GitHub does not provide shell access.

---

## GitHub CLI

Check authentication:

```powershell
gh auth status
```

View the current GitHub repository:

```powershell
gh repo view
```

List issues:

```powershell
gh issue list
```

List pull requests:

```powershell
gh pr list
```

---

## Safe Commit Workflow

Use this sequence before every public commit:

```text
1. Save files
2. git status
3. git diff
4. Run repository safety scanner
5. git add <intended files>
6. git status
7. git diff --cached
8. git commit -m "Meaningful message"
9. git log --oneline --decorate -5
10. git push
```

---

## Secret Exposure

If a secret is accidentally committed:

1. Revoke or rotate the credential immediately.
2. Determine whether the commit reached GitHub.
3. Stop additional pushes.
4. Remove the secret from Git history if necessary.
5. Re-scan the repository.

Deleting the current copy of the file does **not** automatically remove it from Git history.

---

## Most Important Commands to Remember

```powershell
git status
git diff
git add FILE
git diff --cached
git commit -m "Message"
git pull
git push
git log --oneline
```