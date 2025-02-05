const express = require('express');
const { addComment, getCommentsByPost, deleteComment,getCommentCountByPost } = require('../controllers/commentController');
const { protect } = require('../middlewares/authMiddleware');


const router = express.Router();

// Route to add a comment to a post
router.post('/posts/:postId/comments', protect, addComment);

// Route to get all comments for a specific post
router.get('/posts/:postId/comments', getCommentsByPost);

// Route to delete a specific comment
router.delete('/:commentId', protect, deleteComment);
router.get('/posts/:postId/comments/count', getCommentCountByPost);
  

module.exports = router;
