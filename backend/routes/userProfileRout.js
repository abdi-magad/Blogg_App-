const express = require('express');
const multer = require('multer');
const path = require('path');
const { updateUserProfile, getUserProfile } = require('../controllers/userProfile');
const { protect } = require('../middlewares/authMiddleware');

// Multer setup for handling file uploads
const router = express.Router();
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Ensure 'uploads/' directory exists
    cb(null, 'uploads/');
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
    const extname = fileTypes.test(path.extname(file.originalname).toLowerCase());
    const mimeType = fileTypes.test(file.mimetype);

    if (extname && mimeType) {
      return cb(null, true);
    } else {
      cb(new Error('Only images are allowed!'));
    }
  },
});

// Routes
// router.get('/user/:id', protect, getUserProfile);
router.put('/user/:id', protect, upload.single('profilePic'), updateUserProfile);


module.exports = router;
