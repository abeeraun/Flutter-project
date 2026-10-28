# StudyFlow — Final Setup Guide

## 1. Backend: PHP + MySQL + XAMPP

1. Copy the included `studyflow_api` folder to:
   `C:\xampp\htdocs\studyflow_api`
2. Open XAMPP and start **Apache** and **MySQL**.
3. Open `http://localhost/phpmyadmin`.
4. Import `studyflow_api/database.sql`.
5. Verify the API in the PC browser:
   `http://localhost/studyflow_api/subjects`
6. A successful response is JSON with `success: true` and a `data` array.

The API uses PDO prepared statements, JSON responses, input validation, and foreign keys with cascade deletion.

## 2. Flutter

From the project directory:

```bash
flutter pub get
```

The Android manifest already contains Internet permission and allows cleartext HTTP for the local XAMPP API.

### Android Emulator

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2/studyflow_api
```

### Physical Android phone

The phone and PC must be connected to the same Wi-Fi network.

1. Find the PC's local IPv4 address with `ipconfig`.
2. Example: `192.168.1.10`.
3. Start Apache and MySQL.
4. Verify from the phone browser:
   `http://192.168.1.10/studyflow_api/subjects`
5. Run Flutter with:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10/studyflow_api
```

Replace the example IP with the actual PC IPv4 address.

### Chrome / Windows on the PC

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost/studyflow_api
```

## 3. Final End-to-End Test

### Subjects

- Load existing subjects.
- Add a new subject.
- Edit it.
- Search for it.
- Delete it.

### Tasks

- Add a task linked to a subject.
- Edit title, date, priority, and status.
- Test search and filters.
- Delete the task.

### Exams

- Add an upcoming exam.
- Edit it.
- Mark an exam completed and enter an obtained mark.
- Verify the percentage and average score.
- Delete it.

### Dashboard

- Pull down to refresh.
- Confirm subject count, incomplete task count, upcoming exam count, and completion rate.
- Confirm today's priorities contain only unfinished tasks due today or later.
- Confirm upcoming exams contain only upcoming exams whose date has not passed.

### Cascade Delete

Create a subject with at least one task and one exam, then delete the subject. The related task and exam should also disappear because the database uses `ON DELETE CASCADE`.

## 4. Troubleshooting

### API does not open

Check that Apache is running and that the folder is exactly inside `htdocs/studyflow_api`.

### API returns an Apache HTML page

Check Apache `mod_rewrite`, then restart Apache.

### MySQL error

Confirm MySQL is running and that `studyflow_db` was created by importing `database.sql`.

### Phone cannot reach API

Confirm both devices are on the same Wi-Fi, use the PC's IPv4 address rather than `localhost`, and allow Apache through Windows Firewall on the private network.

### App works on emulator but not phone

The emulator uses `10.0.2.2` to reach the host PC. A physical phone must use the PC's LAN IPv4 address.

## 5. Submission Checklist

- [ ] `lib/` included
- [ ] `pubspec.yaml` included
- [ ] Android project included
- [ ] `studyflow_api/` included
- [ ] `database.sql` included
- [ ] No build/cache folders included
- [ ] Apache + MySQL tested
- [ ] CRUD tested end to end
- [ ] Physical phone connection tested if the demo will use a phone
