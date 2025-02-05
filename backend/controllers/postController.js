const asyncHandler = require('express-async-handler');
const Post = require('../models/postModel');
const mongoose = require('mongoose');
const User = require('../models/userModel')


// Create a new post
const createPost = asyncHandler(async (req, res) => {
  const { title, content } = req.body;

  if (!title || !content) {
    res.status(400);
    throw new Error('Title and content are required');
  }

  const image = req.file ? `/uploads/${req.file.filename}` : '';

  const post = await Post.create({
    user: req.user.id,
    title,
    content,
    image,
  });

  if (post) {
    res.status(201).json({ success: true, post });
  } else {
    res.status(400);
    throw new Error('Failed to create post');
  }
});




// In your controller function, ensure ObjectId is used correctly

const getPosts = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : null; // Get the logged-in user's ID, if available

    // Aggregate posts with user, like, and comment data
    const posts = await Post.aggregate([
      {
        $lookup: {
          from: 'users', 
          localField: 'likes',
          foreignField: '_id',
          as: 'likedUsers',
        },
      },
      {
        $addFields: {
          likeCount: { $size: '$likedUsers' }, // Calculate the number of likes
          hasLiked: {
            $in: [userId ? new mongoose.Types.ObjectId(userId) : null, '$likes'], // Check if the current user has liked the post
          },
        },
      },
      {
        $lookup: {
          from: 'comments', // Look up comments associated with the post
          localField: '_id',
          foreignField: 'post',
          as: 'comments',
        },
      },
      {
        $addFields: {
          commentCount: { $size: '$comments' }, // Calculate the number of comments
        },
      },
      {
        $lookup: {
          from: 'users',
          localField: 'user', 
          foreignField: '_id', 
          as: 'userData',
        },
      },
      {
        $addFields: {
          username: { $arrayElemAt: ['$userData.username', 0] },
          userProfilePicture: { $arrayElemAt: ['$userData.profilePic', 0] }, 
          userId: { $arrayElemAt: ['$userData._id', 0] }, 
          email: { $arrayElemAt: ['$userData.email', 0] }, 
          userBio: { $arrayElemAt: ['$userData.bio', 0] }, 
        },
      },
      {
        $sort: { createdAt: -1 },
      },
    ]);

    res.json(posts); 
  } catch (error) {
    console.error('Error fetching posts:', error);
    res.status(500).json({ message: 'Error fetching posts', error: error.message });
  }
};


// Get Single Post
const getPostById = asyncHandler(async (req, res) => {
  const post = await Post.findById(req.params.id)
    .populate('user', 'username profilePic')
    .populate('comments');

  if (!post) {
    res.status(404);
    throw new Error('Post not found');
  }

  res.json(post);
});

// Update Post
const updatePost = asyncHandler(async (req, res) => {
  const post = await Post.findById(req.params.id);

  if (!post) {
    res.status(404);
    throw new Error('Post not found');
  }

  if (post.user.toString() !== req.user.id) {
    res.status(401);
    throw new Error('Not authorized');
  }

  post.title = req.body.title || post.title;
  post.content = req.body.content || post.content;

  if (req.file) {
    post.image = `/uploads/${req.file.filename}`;
  }

  const updatedPost = await post.save();
  res.json(updatedPost);
});

// Delete Post
const deletePost = asyncHandler(async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      res.status(404);
      throw new Error('Post not found');
    }

    // Check if the user is authorized to delete the post
    if (post.user.toString() !== req.user.id) {
      res.status(401);
      throw new Error('Not authorized to delete this post');
    }

    // Delete the post using findByIdAndDelete
    await Post.findByIdAndDelete(req.params.id);

    res.json({ message: 'Post removed successfully' });
  } catch (error) {
    console.error('Error while deleting post:', error);
    res.status(500);
    throw new Error('Failed to delete post');
  }
});

const updateLikes = asyncHandler(async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    const userId = req.user.id;
    const hasLiked = post.likes.includes(userId); 

    if (hasLiked) {
      post.likes = post.likes.filter((id) => id.toString() !== userId);
    } else {
      post.likes.push(userId);
    }

    await post.save();

    res.status(200).json({
      message: 'Likes updated',
      likes: post.likes.length,  
      hasLiked: !hasLiked,
    });
  } catch (error) {
    res.status(500).json({ message: 'Failed to update likes', error: error.message });
  }
});

// Get like count for a specific post
const getLikeCountByPost = asyncHandler(async (req, res) => {
  const { postId } = req.params;

  if (!mongoose.Types.ObjectId.isValid(postId)) {
    return res.status(400).json({ message: 'Invalid post ID.' });
  }

  try {
    const likeCount = await Post.aggregate([
      { $match: { _id: new mongoose.Types.ObjectId(postId) } },
      {
        $lookup: {
          from: 'users',
          localField: 'likes',
          foreignField: '_id', 
          as: 'likedUsers',
        },
      },
      {
        $project: {
          _id: 1,
          title: 1,
          likeCount: { $size: '$likedUsers' },
        },
      },
    ]);

    if (likeCount.length === 0) {
      return res.status(404).json({ message: 'Post not found.' });
    }

    res.status(200).json(likeCount[0]);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});


const updateUserProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);

  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found.' });
  }

  const { username, bio } = req.body;

  if (username) user.username = username;
  if (bio) user.bio = bio;
  if (req.file) user.profilePic = `/uploads/${req.file.filename}`;

  const updatedUser = await user.save();

  res.json({
    success: true,
    message: 'Profile updated successfully.',
    data: {
      username: updatedUser.username,
      bio: updatedUser.bio,
      profilePic: updatedUser.profilePic,
    },
  });
});

const getUserProfile = async (req, res) => {
  try {
    // Find user by ID, excluding password field
    const user = await User.findById(req.params.id).select('-password');
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.status(200).json({
      username: user.username,
      email: user.email,
      profilePic: user.profilePic,
      bio: user.bio,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

const getSearchPosts = asyncHandler(async (req, res) => {
  const { keyword } = req.query; // Get the search keyword from the query

  try {
    const posts = await Post.find({
      $or: [
        { title: { $regex: keyword, $options: 'i' } }, 
        { content: { $regex: keyword, $options: 'i' } }, 
      ],
    }).populate('user', 'username profilePic');
    console.log(req.params.id);

    res.status(200).json(posts);
  } catch (error) {
    res.status(500).json({ message: 'Error searching posts', error: error.message });
  }
});


module.exports = {
  createPost,
  getPosts,
  updatePost,
  deletePost,
  updateLikes,
  getLikeCountByPost,
  getUserProfile,
  updateUserProfile,
  getSearchPosts,
  getPostById
};