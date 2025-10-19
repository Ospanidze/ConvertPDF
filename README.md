# 📘 ConvertPDF  

> iOS приложение для создания, объединения и управления PDF-документами из фотографий и файлов.


## 🚀 Возможности  

- 📷 Создание PDF из фотографий (галерея или камера)  
- 📂 Импорт файлов из “Files” (PDF, JPG, PNG, HEIC)  
- 🔗 Объединение нескольких PDF в один  
- 🧾 Удаление страниц прямо в читалке  
- 📤 Возможность поделиться PDF  
- 🖼 Миниатюры документов (thumbnails)  
- 💾 Сохранение через **Core Data**  
- 🎨 Современный интерфейс на **SwiftUI**

---

## 🧠 Архитектура  

Архитектура — **MVVM** без сторонних зависимостей.  

| Модуль | Назначение |
|--------|-------------|
| `DocumentListScreen` | Главный экран со списком документов |
| `DocumentListViewModel` | Управление Core Data и импортом |
| `PDFViewerView` | Просмотр и редактирование PDF |
| `PDFGeneratorManager` | Генерация и объединение PDF |
| `DocumentImportManager` | Импорт файлов из системы |
| `PDFDataManager` | Работа с Core Data |
| `PermissionManager` | Проверка и запрос разрешений |
| `PhotoPicker`, `FilePicker` | Нативные контроллеры выбора |

---

## 🧩 Технологии  
 
- **SwiftUI**  
- **PDFKit**  
- **Core Data**  
- **UniformTypeIdentifiers (UTType)**  
- **UIKit (UIViewRepresentable / UIActivityViewController)**  
- **Concurrency (async/await)**

---

## 💾 Хранение данных  

PDF сохраняются в `Documents/`,  
а их метаданные — в **Core Data (PDFEntity)**:  

```swift
PDFEntity {
  id: UUID
  name: String
  filePath: String
  createdAt: Date
  thumbnail: Data?
}
