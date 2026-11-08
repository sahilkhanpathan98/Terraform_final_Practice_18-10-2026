# Git – Specific Folder Push & Upstream Tracking

## 1. Specific Folder ki Particular Files ko Stage Kaise Karein?

Maan lo tumhare local project mein ye folder hai:

```text
Terraform_final_Practice/
│
└── Terraform_modulet_files/
    │
    ├── GitHub Module main.tf
    └── Terraform Registry main.tf
```

Tumhe sirf ye 2 files GitHub par upload karni hain.

### Step 1 – Specific Files ko Stage Karna

```bash
git add "Terraform_modulet_files/GitHub Module main.tf"

git add "Terraform_modulet_files/Terraform Registry main.tf"
```

**Meaning:**
- `git add` = File ko staging area mein add karna.
- `Terraform_modulet_files/` = Folder ka path.
- `GitHub Module main.tf` = Particular file ka naam.

Ab sirf ye 2 files staging area mein jayengi.

### Step 2 – Status Check Karna

```bash
git status
```

Isse pata chalega ki kaunsi files staged hain aur kaunsi unstaged.

### Step 3 – Commit Karna

```bash
git commit -m "Add Terraform module main.tf files"
```

Commit ka meaning hai staging area mein selected changes ka snapshot local repository mein save karna.

### Step 4 – GitHub par Push Karna

```bash
git push origin master
```

Isse committed changes GitHub ki `master` branch par upload ho jayenge.

---

## 2. git push vs git push origin master

| Command | Meaning |
|---|---|
| `git push` | Configured upstream branch par commits push karta hai |
| `git push origin master` | Explicitly origin remote ki master branch par push karta hai |

### Command Breakdown

```bash
git push origin master
```

- `git push` = Commits upload karo.
- `origin` = Remote repository ka naam.
- `master` = Target branch.

---

## 3. Sirf git push Kab Kaam Karta Hai?

Jab local branch ka upstream tracking already configured ho.

Example:

```text
Local Repository                 GitHub

Local master  ---------------->  origin/master
                  Tracking
```

Agar upstream tracking set hai, toh:

```bash
git push
```

Git automatically corresponding remote branch identify kar lega.

---

## 4. Upstream Tracking Kya Hai?

Upstream tracking ka meaning hai local branch ko uski corresponding remote-tracking branch ke saath connect karna.

Example:

- Local branch = `master`
- Remote name = `origin`
- Remote-tracking branch = `origin/master`

Is connection ki wajah se Git ko automatically pata rehta hai ki push aur pull kahan karna hai.

---

## 5. -u Ka Purpose Kya Hai?

```bash
git push -u origin master
```

`-u` ka full form hai:

`--set-upstream`

Ye command:
1. Local commits ko GitHub par push karti hai.
2. Local `master` branch ka upstream `origin/master` set karti hai.

Uske baad baar-baar `-u` lagane ki zaroorat nahi hoti.

Next time:

```bash
git push
git pull
```

---

## 6. Local aur Remote Mein Same Folder Present Ho Toh Kya Hoga?

Maan lo `Terraform_modulet_files` folder local aur GitHub dono mein already present hai.

### Before Push

**Local Computer:**

```text
Terraform_modulet_files/
│
├── GitHub Module main.tf
└── Terraform Registry main.tf
```

**GitHub:**

```text
Terraform_modulet_files/
│
└── Existing files
```

Ab local se dono files ko stage, commit aur push karte ho.

### After Push

**GitHub:**

```text
Terraform_modulet_files/
│
├── Existing files
├── GitHub Module main.tf
└── Terraform Registry main.tf
```

Dono files existing `Terraform_modulet_files` folder ke andar hi upload hongi.

Git unka folder path preserve karta hai.

---

## 7. Kya git push Particular Folder Select Karta Hai?

**Nahi!**

- `git add` = Decide karta hai kaunsi files staging area mein jayengi.
- `git commit` = Staged changes ka local snapshot banata hai.
- `git push` = Local commits ko remote branch par upload karta hai.

`git push` kisi particular folder ko select nahi karta.

---

## 8. Complete Git Workflow – Sequence

```text
Local Computer
      |
      v
Terraform_modulet_files/
      |
      v
Select Particular Files
      |
      v
git add
      |
      v
Staging Area
      |
      v
git status
      |
      v
git commit
      |
      v
Local Repository
      |
      v
git push origin master
      |
      v
GitHub Repository
      |
      v
Terraform_modulet_files/
      |
      v
Both Files Uploaded
```

## 9. Quick Revision

| Command | Purpose |
|---|---|
| `git add file_path` | Particular file stage karna |
| `git add folder/` | Folder ke changes stage karna |
| `git status` | Staged aur unstaged changes check karna |
| `git commit -m "message"` | Local snapshot create karna |
| `git push origin master` | Origin ki master branch par push karna |
| `git push -u origin master` | Push + upstream tracking set karna |
| `git push` | Configured upstream par push karna |

## 10. Interview Answer

Git add is used to stage specific files or folders. Git commit saves the staged changes as a local snapshot, and git push uploads committed changes to the remote repository.

Upstream tracking connects a local branch with its corresponding remote-tracking branch, allowing Git to automatically identify the remote branch for future push and pull operations.