const mongoose = require('mongoose');
const User = require('../models/userModel'); 

/**
 * Get User Profile with Posts, Comments, and Liked Posts
 * @route GET /api/user/:id
 * @param {Object} req - Request object
 * @param {Object} res - Response object
 */
const getUserProfile = async (req, res) => {
  const userId = req.params.id;

  if (!mongoose.Types.ObjectId.isValid(userId)) {
    return res.status(400).json({ message: 'Invalid user ID format' });
  }

  try {
    const userProfile = await User.aggregate([
      {
        // Match the user by ID
        $match: { _id: new mongoose.Types.ObjectId(userId) },
      },
      {
        // Lookup posts made by the user
        $lookup: {
          from: 'posts',
          localField: '_id',
          foreignField: 'user',
          as: 'posts',
        },
      },
      {
        // Lookup posts liked by the user
        $lookup: {
          from: 'posts',
          localField: '_id',
          foreignField: 'likes',
          as: 'likedPosts',
        },
      },
      {
        // Unwind posts array for lookup with comments
        $unwind: {
          path: '$posts',
          preserveNullAndEmptyArrays: true,
        },
      },
      {
        // Lookup comments for each post
        $lookup: {
          from: 'comments',
          localField: 'posts._id',
          foreignField: 'post',
          as: 'posts.comments',
        },
      },
      {
        // Group posts back into an array
        $group: {
          _id: '$_id',
          username: { $first: '$username' },
          email: { $first: '$email' },
          profilePic: { $first: '$profilePic' },
          posts: { $push: '$posts' },
          likedPosts: { $push: '$likedPosts' },
        },
      },
      {
        // Project the fields we need
        $project: {
          username: 1,
          email: 1,
          profilePic: 1,
          posts: {
            _id: 1,
            title: 1,
            content: 1,
            image: 1,
            likes: 1,
            hasLiked: { $in: [new mongoose.Types.ObjectId(userId), '$likes'] },
            comments: {
              _id: 1,
              content: 1,
              user: 1,
            },
          },
          likedPosts: {
            _id: 1,
            title: 1,
            content: 1,
            image: 1,
            likes: 1,
          },
        },
      },
    ]);

    if (!userProfile || userProfile.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json(userProfile[0]); 
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

/**
 * Update User Profile
 * @route PUT /api/user/:id
 * @param {Object} req - Request object
 * @param {Object} res - Response object
 */
const updateUserProfile = async (req, res) => {
  try {
    const userId = req.params.id;
    const { username } = req.body;

    const updatedData = { username };

    if (req.file) {
      const profilePicPath = req.file.path;
      updatedData.profilePic = profilePicPath; 
    }

    const updatedUser = await User.findByIdAndUpdate(userId, updatedData, { new: true });

    if (!updatedUser) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({
      message: 'Profile updated successfully',
      user: updatedUser,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Failed to update profile' });
  }
};
module.exports = {
  getUserProfile,
  updateUserProfile
};
