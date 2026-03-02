# Day du an len GitHub va build iOS

## Buoc 1: Tao repository moi tren GitHub

1. Vao https://github.com/new
2. Dat ten repo (vd: `toanha_vi_tri`)
3. Chon Public hoac Private
4. **Khong** tick "Add a README" (da co code local)
5. Nhan "Create repository"

## Buoc 2: Ket noi va day code

Trong PowerShell tai thu muc du an (`d:\TVU\toanha_vi_tri`), chay:

```powershell
git remote add origin https://github.com/TEN_USER_GITHUB/TEN_REPO.git
git branch -M main
git push -u origin main
```

Thay `TEN_USER_GITHUB` va `TEN_REPO` bang username GitHub va ten repo cua ban.

Vi du: neu username la `tvu` va repo la `toanha_vi_tri`:

```powershell
git remote add origin https://github.com/tvu/toanha_vi_tri.git
git branch -M main
git push -u origin main
```

## Buoc 3: Chay build iOS tren GitHub Actions

1. Vao repo tren GitHub
2. Tab **Actions**
3. Chon workflow **Build Unsigned iOS IPA**
4. Nhan **Run workflow** (nut "Run workflow" mau xanh)
5. Cho chay xong, vao job vua chay
6. Phan **Artifacts** se co file `unsigned-ipa` (app.ipa) - nhan de tai ve

Luu y: IPA build bang workflow nay la **unsigned** (chua ky). De caidat len thiet bi that can ky lai hoac dung dang development/ad-hoc.
