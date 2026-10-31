# Git Case Study – Accidental Commit, Hard Reset & File Recovery

## Quick Summary – Mere saath kya hua?

Mere saath Git mein 2 problems hui:

### 1. Accidental `.terraform/` Commit
- Maine `git add .` aur `git commit` kiya.
- Galti se `.terraform/` folder bhi commit ho gaya.
- Is folder mein AWS provider ki 685 MB ki `.exe` file thi.
- `git push origin master` karne par GitHub ne 100 MB limit ki wajah se push reject kar diya.

### 2. Hard Reset ke baad Files Missing
- Push problem solve karne ke liye maine `git reset --hard origin/master` run kiya.
- Isse local branch remote ke latest commit par reset ho gayi.
- Mere newer local commit ki kuch tracked Terraform files working directory se missing ho gayi.
- Maine `git reflog` se old commit `8cae01d` find kiya aur `git restore` se files recover kar li.

### Complete Flow

```text
       ACCIDENTAL COMMIT
               |
               v
       .terraform/ included
               |
               v
          PUSH FAILED
       685 MB > 100 MB
               |
               v
       git reset --hard
         origin/master
               |
               v
       TRACKED FILES MISSING
               |
               v
       git reflog --all
               |
               v
       OLD COMMIT FOUND
           8cae01d
               |
               v
       git ls-tree (verify)
               |
               v
       git restore (recover)
               |
               v
       FILES RECOVERED
```

---

# CASE 1 – Accidental `.terraform/` Commit & Push Failure

## 1. Maine kya galti ki?

Mere Terraform project mein actual configuration files ke saath `.terraform/` folder bhi tha.

```text
Terraform-Target-Dependency/
│
├── .terraform/
│   └── providers/
│       └── terraform-provider-aws.exe
│
├── .terraform.lock.hcl
├── main.tf
├── provider.tf
├── variables.tf
└── terraform.tfvars
```

Maine `.gitignore` banaye bina commands run kar di:

```bash
git add .
git commit -m "Terraform dependency notes"
```

**Meri galti:**
- Maine poora project Git mein add kar diya.
- `.terraform/` folder bhi commit ho gaya.
- Is folder mein unnecessary downloaded provider files thi.

## 2. Push fail kyun hua?

Maine command run ki:

```bash
git push origin master
```

GitHub ne push reject kar diya, kyunki AWS provider executable file approximately 685 MB ki thi aur GitHub ki individual file limit 100 MB hai.

### Flow Diagram

```text
      LOCAL PROJECT
            |
            v
         git add .
            |
            v
        git commit
            |
            v
   .terraform included
            |
            v
   git push origin master
            |
            v
     GITHUB VALIDATION
            |
            v
      685 MB > 100 MB
            |
            v
       PUSH REJECTED
```

**Maine kya samjha?**

- `git commit` changes ko local repository mein save karta hai.
- `git push` local commits ko GitHub par upload karta hai.
- Push fail hone ka matlab local commit delete hona nahi hai.
- `.terraform/` folder ko Git mein commit nahi karna chahiye.

---

# CASE 2 – Hard Reset ke baad Files Missing & Recovery

## 1. Maine doosri galti kya ki?

Push reject hone ke baad maine local branch ko remote ke same state mein lane ke liye command run ki:

```bash
git reset --hard origin/master
```

### Is command ne kya kiya?

- Local branch ko `origin/master` ke commit par move kar diya.
- Staging area reset kar diya.
- Tracked working-directory files ko remote commit ke snapshot ke according reset kar diya.
- Newer local commit branch history se hat gaya.

### Before Reset

```text
       LOCAL MASTER
             |
             v
          8cae01d
             |
             v
          384620f
             |
             v
        ORIGIN/MASTER
```

- `8cae01d` = Newer local commit.
- `384620f` = GitHub par available latest commit.

### After Reset

```text
       LOCAL MASTER
             |
             v
          384620f
             |
             v
        ORIGIN/MASTER
```

Ab local master aur origin/master same commit par aa gaye.

## 2. Files missing kyun hui?

Mere newer local commit `8cae01d` mein Terraform ki kuch tracked files present thi.

Lekin remote commit `384620f` mein woh files nahi thi.

Jab maine `git reset --hard origin/master` kiya, Git ne working directory ko remote commit ke snapshot ke according reset kar diya.

Isliye newer commit mein present kuch tracked files working directory se missing ho gayi.

### Flow Diagram

```text
      NEWER LOCAL COMMIT
              |
              v
      Terraform files present
              |
              v
   git reset --hard origin/master
              |
              v
       REMOTE COMMIT CHECK
              |
              v
    Newer files remote mein nahi
              |
              v
       WORKING DIRECTORY RESET
              |
              v
         FILES MISSING
```

**Meri galti:** Maine `git reset --hard` run karne se pehle apne important local changes ka backup nahi liya.

> Note: `git reset --hard` tracked files ke uncommitted changes discard kar sakta hai. Untracked files generally is command se delete nahi hoti.

## 3. Mujhe kaise pata chala ki files recover ho sakti hain?

Mujhe yaad tha ki maine pehle Terraform files ka commit banaya tha.

Maine command run ki:

```bash
git reflog --all
```

Output mein mujhe old commit mila:

```text
8cae01d HEAD@{3}: commit: Terraform-Target-Dependency notes
```

### `git reflog` ne kaise help ki?

`git reflog` HEAD aur branch references ki recent movements ka record rakhta hai.

Isse mujhe reset se pehle wala commit `8cae01d` mil gaya.

```text
       OLD COMMIT
        8cae01d
            |
            v
      HARD RESET
            |
            v
     CURRENT COMMIT
        384620f
            |
            v
      git reflog
            |
            v
      OLD COMMIT FOUND
```

**Maine kya samjha?**

Meri files ka snapshot old commit mein abhi bhi available tha. Isliye main unhe recover kar sakta tha.

## 4. Maine old commit mein files verify kaise ki?

Command:

```bash
git ls-tree -r --name-only 8cae01d
```

Output mein ye files mili:

```text
.terraform.lock.hcl
.terraform/providers/...
dependency-flow.md
main.tf
md-summary.md
provider.tf
terraform.tfvars
variables.tf
```

Isse confirm hua ki meri required Terraform files old commit mein saved thi.

## 5. Maine files recover kaise ki?

Repository root directory se ye command run ki:

```bash
git restore --source=8cae01d --worktree -- Terraform-Target-Dependency/
```

### Command ka breakdown

| Command Part | Meaning |
|---|---|
| `git restore` | Files restore karna |
| `--source=8cae01d` | Old commit se files lena |
| `--worktree` | Working directory mein files lana |
| `--` | Iske baad folder ka path |
| `Terraform-Target-Dependency/` | Recover karne wala folder |

### Is command ne kya kiya?

Git ne `8cae01d` commit se `Terraform-Target-Dependency/` folder ki files lekar current working directory mein restore kar di.

**Important:** `git restore` ne branch ko old commit par move nahi kiya. Sirf selected folder ki files recover ki.

### Recovery Flow

```text
       git reflog --all
               |
               v
       OLD COMMIT FOUND
           8cae01d
               |
               v
       git ls-tree
               |
               v
       FILES VERIFIED
               |
               v
       git restore
               |
               v
       FILES RESTORED
               |
               v
       RECOVERY SUCCESSFUL
```

## 6. Recovery successful kaise verify ki?

Command:

```bash
ls -la Terraform-Target-Dependency
```

Output:

```text
.terraform/
.terraform.lock.hcl
dependency-flow.md
main.tf
md-summary.md
provider.tf
terraform.tfvars
variables.tf
```

**Result:** Meri important Terraform files successfully recover ho gayi.

---

# FINAL STEP – `.gitignore` se Future Mistake Avoid ki

## 1. `.gitignore` create ki

Repository root mein `.gitignore` file banayi:

```gitignore
**/.terraform/
*.tfstate
*.tfstate.*
**/terraform.tfvars
```

### Purpose

| Pattern | Purpose |
|---|---|
| `**/.terraform/` | Har level par `.terraform/` folder ignore karna |
| `*.tfstate` | Terraform state files ignore karna |
| `*.tfstate.*` | State backup files ignore karna |
| `**/terraform.tfvars` | Variable values wali files ignore karna |

**Important:**
- `.gitignore` untracked files ko ignore karta hai.
- Already tracked files automatically untrack nahi hoti.
- `.terraform.lock.hcl` ko generally Git mein commit karna chahiye.
- Agar `terraform.tfvars` mein sensitive values hain, toh use Git mein commit nahi karna chahiye.

Agar `.terraform/` pehle se tracked hai, toh:

```bash
git rm -r --cached -- Terraform-Target-Dependency/.terraform/
```

Is command se Git tracking se folder remove hota hai, lekin local files delete nahi hoti.

## 2. Required files commit aur push ki

```bash
git status
git add .
git status
git commit -m "Add Terraform dependency notes"
git push origin master
```

### Final Flow

```text
      FILES RECOVERED
              |
              v
       CREATE .gitignore
              |
              v
       .terraform ignored
              |
              v
         git status
              |
              v
           git add .
              |
              v
          git commit
              |
              v
           git push
              |
              v
        GITHUB UPDATED
```

---

# Quick Revision – Maine kya galat kiya, kya hua aur kaise fix kiya?

| Step | Maine kya kiya? | Kya hua? | Solution |
|---|---|---|---|
| 1 | `git add .` | `.terraform/` bhi stage ho gaya | `.gitignore` banana chahiye tha |
| 2 | `git commit` | Large provider file commit ho gayi | Unnecessary folder ko exclude karna tha |
| 3 | `git push origin master` | GitHub ne push reject kar diya | Push error check kiya |
| 4 | `git reset --hard origin/master` | Newer tracked files missing hui | Old commit find kiya |
| 5 | `git reflog --all` | Previous commit locate karna tha | `8cae01d` mila |
| 6 | `git ls-tree` | Old commit mein files verify ki | Files available confirm hui |
| 7 | `git restore` | Files working directory mein chahiye thi | Files recover ki |
| 8 | `.gitignore` | Future mein unwanted files rokni thi | `.terraform/` ignore kiya |
| 9 | `git add`, `commit`, `push` | Clean project upload karna tha | Required files push ki |

# Interview Answer

"During my Terraform practice, I accidentally committed the `.terraform` directory along with my source files. It contained an AWS provider executable of approximately 685 MB, so GitHub rejected my push because the individual file exceeded the 100 MB limit.

While trying to fix the issue, I ran `git reset --hard origin/master`. This moved my local branch back to the remote commit and caused some tracked files from my newer local commit to disappear from the working directory.

To recover them, I used `git reflog --all` to find my previous commit. I verified the files using `git ls-tree` and restored them using `git restore --source=<commit-id> --worktree -- <path>`.

Finally, I created a `.gitignore` file to exclude `.terraform` and Terraform state files, and then pushed only the required project files."

# Remember – 5 Important Points

1. **Commit** = Local repository mein snapshot save hota hai.
2. **Push Failed** = Local commit automatically delete nahi hota.
3. **Hard Reset** = Local branch aur tracked working files reset hote hain.
4. **Reflog + Restore** = Old commit find karke files recover kar sakte hain.
5. **`.gitignore`** = Untracked unwanted files ko future commits mein aane se rokta hai.

**Final Learning:** `git add .` se pehle `.gitignore` check karo aur `git reset --hard` run karne se pehle important commits aur changes ka backup zaroor rakho.