# Topic 3 – Count vs For_each

## Basic difference

- `count` = number/index based.
- `for_each` = key based.

| Feature | count | for_each |
|---|---|---|
| Input | Number | Set or Map |
| Identity | Numeric index | Key |
| Address example | `example.item[0]` | `example.item["dev"]` |
| Useful when | Similar numbered copies | Named items with distinct identity |

## Count index shifting

Initial list:

```text
Index:       0       1       2
Value:      dev     test    prod
```

Remove `test`:

```text
Index:       0       1
Value:      dev     prod
```

Ab `prod` ka index 2 se 1 ho gaya. Terraform index-based instances ko compare karega. Resource ke attributes aur provider behavior ke hisaab se update ya replacement ho sakta hai; har case mein destroy/recreate guaranteed nahi hai.

## For_each key identity

Initial keys:

```text
dev     test     prod
```

Remove `test`:

```text
dev              prod
```

`dev` aur `prod` ki keys same rehti hain. Normally sirf removed key ka instance destroy hota hai.

## Visual comparison

```text
COUNT                         FOR_EACH
-----                         --------
[0] = dev                     ["dev"]  = dev
[1] = test                    ["test"] = test
[2] = prod                    ["prod"] = prod
       |                              |
 Remove test                    Remove test
       |                              |
 [0] = dev                      ["dev"]  = dev
 [1] = prod                      ["prod"] = prod
 Index mapping changed          Remaining keys stable
```

## Kab kya use karein?

- Fixed number of similar instances: `count`.
- Named resources, jaise `dev`, `test`, `prod`: `for_each`.
- Agar har item ki identity important hai, generally `for_each` clearer choice hota hai.

## Interview answer

`count` identifies instances by numeric indexes, while `for_each` identifies instances by map keys or set elements. This makes `for_each` more suitable when each instance has a meaningful, stable key.
