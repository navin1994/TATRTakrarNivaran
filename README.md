# ताडोबा संवाद

A new Flutter project to manage the **Complaints, Registrations and Leaves** at **Tadoba Andheri Tiger Reserve**.

---

## Command-line Instructions

- Clone this git repository `git clone https://github.com/navin1994/TATRTakrarNivaran.git`.
- Open project directory in terminal and get packages listed inside the _pubspec.yaml_ file using command `flutter pub get`.
- Connect your real device (which should have USB debugging on under developer option) or create emulator and then run project using `flutter run`.

---

## Some usefull commands while development

- To generate translations file fot easy localization `flutter pub run easy_localization:generate -S "assets/translations" -O "lib/translations"`.
- To generate keys of translation file `flutter pub run easy_localization:generate -S "assets/translations" -O "lib/translations" -o "locale_keys.g.dart" -f keys`.
- To change the package name using command `flutter pub run change_app_package_name:main com.new.package.name`.
- To generate the release build of project `flutter build apk --split-per-abi`.
