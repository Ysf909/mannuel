Hutopia Auth (MVVM) - Sign In + Sign Up (same page)

✅ What you asked:
- Sign Up page implemented
- NOT a new view page: switching happens inside the SAME page (AnimatedSwitcher + VM toggle)
- Widgets are built with code (fields/buttons/social), NOT using exported button images
- Uses your design sizes:
  - base frame: 430 x 932
  - fields: 398 x 60
  - main button: 398 x 56
  - social buttons: 56 x 56
- No auth / no DB: on submit it navigates to /home (placeholder)

How to use:
1) Copy folders:
   - lib/...
   - assets/auth/hutopia.png

2) pubspec.yaml:
   dependencies:
     provider: ^6.0.5
   flutter:
     assets:
       - assets/auth/

3) Run:
   flutter clean
   flutter pub get
   flutter run
