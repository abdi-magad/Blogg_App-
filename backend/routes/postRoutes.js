const express = require("express");
const {
  getUserProfile,
  createPost,
  getPosts,
  getPostById,
  updatePost,
  deletePost,
  updateLikes,
  getLikeCountByPost,
  updateUserProfile,
  getSearchPosts,
} = require("../controllers/postController");
const { protect } = require("../middlewares/authMiddleware");
const multer = require("multer");
const path = require("path");

// Multer setup for handling file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Ensure 'uploads/' directory exists
    cb(null, "uploads/");
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}_${file.originalname}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const fileTypes = /jpeg|jpg|png/;
    const extname = fileTypes.test(
      path.extname(file.originalname).toLowerCase()
    );
    const mimeType = fileTypes.test(file.mimetype);

    if (extname && mimeType) {
      return cb(null, true);
    } else {
      cb(new Error("Only images are allowed!"));
    }
  },
});

const router = express.Router();

// Likes route - added 'protect' middleware to ensure user is authenticated before liking a post
router.get("/user/:id", protect, getUserProfile);
router.route("/:id/like").put(protect, updateLikes); // Authentication required
// router.get('/user/:id', getUserProfile);
// Route to get the like count for a specific post
router.get("/:postId/likes/count", getLikeCountByPost);
// router.route('/:id/like').put(updateLikes); // Authentication required

// Routes for post operations
router
  .route("/")
  .get(getPosts) // Get all posts
  .post(protect, upload.single("image"), createPost); // Create a post (authentication required)
router.get("/search", getSearchPosts); // Endpoint for searching posts

router
  .route("/:id")
  .get(getPostById) // Get a single post by ID
  .put(protect, upload.single("profilePic"), updateUserProfile) // Update a post (authentication required)
  .delete(protect, deletePost); // Delete a post (authentication required)
router.get("/user/:id", protect, getUserProfile);

module.exports = router;
