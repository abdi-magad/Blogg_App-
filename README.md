Here's the full README.md content ready for copying:

```markdown
# Blog App 📝

A full-stack blogging platform built with Flutter (frontend) and Node.js + MongoDB (backend). Users can register, login, create posts, like/unlike, comment, manage profiles, and more!

## Features ✨

### Frontend (Flutter)
- **User Authentication**: Secure login & registration
- **Post Management**: 
  - Create new posts with images
  - View/delete your posts
  - Search posts by keyword
- **Social Interactions**:
  - Like/unlike posts ❤️
  - Add/delete comments 💬
- **User Profile**:
  - View post/like statistics 📊
  - See liked posts collection
  - Update profile picture & info
  - Logout functionality 🔒

### Backend (Node.js)
- **REST API** with JWT authentication 🔑
- **MongoDB** database with Mongoose
- **Image Handling**: Upload posts/profile pictures 📸
- **Advanced Features**:
  - Post search functionality 🔍
  - Real-time like/comment counters
  - Protected user-specific actions 🛡️

## Tech Stack 🛠️

| Frontend               | Backend                | Database       |
|------------------------|------------------------|----------------|
| Flutter (Dart)          | Node.js                | MongoDB        |
| http Library            | Express.js             | Mongoose ODM   |
| Getx                    | JWT Authentication     |                |
| Image Picker            | Multer (File Upload)   |                |

-- and more ----

## Setup Guide 🚀

### Backend Setup

1. **Clone Repository**
   ```bash
   git clone https://github.com/Abuubakar-Ciise/Blog-App.git
   cd backend
   ```

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Environment Setup**
   Create `.env` file:
   ```env
   MONGO_URI=mongodb://localhost:27017/lavel-200-blog-app
   JWT_SECRET=your_super_secret_key
   PORT=5000
   ```

4. **Start Server**
   ```bash
   npm start
   ```

### Flutter Setup

1. **Configure Dependencies**
   ```bash
   cd frontend
   flutter pub get
   ```

2. **API Configuration**
   Update `lib/services/api_service.dart`:
   ```dart
   const String baseUrl = 'http://localhost:5000/api'; // or your server IP
   ```

3. **Run Application**
   ```bash
   flutter run
   ```

## API Documentation 📚

### Authentication
| Method | Endpoint            | Description        | Protected |
|--------|---------------------|--------------------|-----------|
| POST   | /api/auth/register  | Create new account | ❌        |
| POST   | /api/auth/login     | Get access token   | ❌        |

### Posts
| Method | Endpoint            | Description          | Protected |
|--------|---------------------|----------------------|-----------|
| GET    | /api/posts          | Get all posts        | ❌        |
| POST   | /api/posts          | Create new post      | ✅        |
| GET    | /api/posts/search   | Search posts         | ❌        |
| GET    | /api/posts/:id      | Get single post      | ❌        |
| DELETE | /api/posts/:id      | Delete post          | ✅        |

### Comments
| Method | Endpoint                        | Description          | Protected |
|--------|---------------------------------|----------------------|-----------|
| POST   | /api/comments/posts/:postId     | Add comment          | ✅        |
| GET    | /api/comments/posts/:postId     | Get comments         | ❌        |
| DELETE | /api/comments/:commentId        | Delete comment       | ✅        |

### User Profile
| Method | Endpoint            | Description          | Protected |
|--------|---------------------|----------------------|-----------|
| GET    | /api/user/:id       | Get profile          | ✅        |
| PUT    | /api/user/:id       | Update profile       | ✅        |

### Likes
| Method | Endpoint                | Description          | Protected |
|--------|-------------------------|----------------------|-----------|
| PUT    | /api/:id/like           | Toggle like          | ✅        |
| GET    | /api/:postId/likes/count| Get like count       | ❌        |

## Contributors 👥

| Name           | GitHub Profile |
|---------------|---------------|
| **Abuubakar Ciise**  | [![GitHub](https://img.shields.io/badge/GitHub-Abuubakar--Ciise-blue)](https://github.com/Abuubakar-Ciise) |
| **Cabduali diiriye**   | [![GitHub](https://img.shields.io/badge/GitHub-Cabduali-blue)](https://github.com/cabduali) |
| **Abaas Muuse**| [![GitHub](https://img.shields.io/badge/GitHub-AbaasMuuse-blue)](https://github.com/abaasmuuse) |
| **Suleymaan** | [![GitHub](https://img.shields.io/badge/GitHub-Caga--Dahab8-blue)](https://github.com/caga-dahab8) |


**Contribution Guidelines** 🤝  
- Fork the repository
- Create your feature branch (`git checkout -b feature/AmazingFeature`)
- Commit changes (`git commit -m 'Add AmazingFeature'`)
- Push to branch (`git push origin feature/AmazingFeature`)
- Open Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
