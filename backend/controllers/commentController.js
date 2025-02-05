const Comment = require('../models/commentModel');
const Post = require('../models/postModel');
const asyncHandler = require('express-async-handler');
const mongoose = require('mongoose')

// Add a comment
const addComment = asyncHandler(async (req, res) => {
  const { postId } = req.params;
  const { content } = req.body;

  console.log('Add Comment Request:', { postId, content, userId: req.user._id });

  // Ensure content is provided
  if (!content || content.trim() === "") {
    console.error('Content is missing or empty.');
    return res.status(400).json({ message: 'Content is required and cannot be empty.' });
  }

  // Check if the post exists
  const post = await Post.findById(postId);
  if (!post) {
    console.error(`Post not found with ID: ${postId}`);
    return res.status(404).json({ message: 'Post not found.' });
  }

  console.log('Post found:', { postId });

  // Create the comment
  const comment = await Comment.create({
    content,
    post: postId,
    user: req.user.id,
  });

  // Add the comment to the post
  post.comments.push(comment._id);
  await post.save();

  console.log('Comment added successfully:', { commentId: comment._id });

  // Send the comment data back in the response
  res.status(201).json(comment);
});

// Get all comments for a post
const getCommentsByPost = asyncHandler(async (req, res) => {
  const { postId } = req.params;
  console.log('Fetching comments for postId:', postId);

  // Ensure the post exists
  const post = await Post.findById(postId);
  if (!post) {
    console.error(`Post not found with ID: ${postId}`);
    return res.status(404).json({ message: 'Post not found.' });
  }

  // Fetch the comments for the post
  const comments = await Comment.find({ post: postId })
    .populate('user', 'username profilePic')
    .sort({ createdAt: -1 });

  res.status(200).json(comments);
});

// Delete a comment
const deleteComment = asyncHandler(async (req, res) => {
  const { commentId } = req.params;

  console.log('Delete Comment Request:', { commentId, userId: req.user._id });

  // Find the comment
  const comment = await Comment.findById(commentId);
  if (!comment) {
    console.error(`Comment not found with ID: ${commentId}`);
    return res.status(404).json({ message: 'Comment not found.' });
  }

  // Ensure the user is authorized to delete the comment
  if (comment.user.toString() !== req.user._id.toString()) {
    console.error(`User ${req.user._id} not authorized to delete comment ${commentId}`);
    return res.status(403).json({ message: 'You do not have permission to delete this comment.' });
  }

  // Remove the comment and update the post
  await comment.deleteOne();

  // Remove comment reference from the post
  const post = await Post.findById(comment.post);
  if (post) {
    post.comments.pull(commentId);
    await post.save();
  }

  console.log('Comment deleted successfully:', { commentId });
  res.status(200).json({ message: 'Comment deleted successfully.' });
});
// Get comment count for a specific post
const getCommentCountByPost = asyncHandler(async (req, res) => {
  const { postId } = req.params;

  // Validate the postId
  if (!mongoose.Types.ObjectId.isValid(postId)) {
    return res.status(400).json({ message: 'Invalid post ID.' });
  }

  const commentCount = await Post.aggregate([
    { $match: { _id: new mongoose.Types.ObjectId(postId) } },
    {
      $lookup: {
        from: 'comments',
        localField: '_id',
        foreignField: 'post',
        as: 'postComments',
      },
    },
    {
      $project: {
        _id: 1,
        title: 1,
        commentCount: { $size: '$postComments' },
      },
    },
  ]);

  if (commentCount.length === 0) {
    return res.status(404).json({ message: 'Post not found.' });
  }

  res.status(200).json(commentCount[0]);
});
module.exports = { addComment, getCommentsByPost, deleteComment, getCommentCountByPost };
