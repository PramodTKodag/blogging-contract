// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract BloggingApp {
    struct BlogPost {
        uint256 id;
        address author;
        string title;
        string body;
        string subBody;
        uint256 timestamp;
        bool isVerified;
        string[] media;
        address[] likers;
    }

    event BlogPostDisliked(
        uint256 indexed id,
        address indexed disliker,
        uint256 likes
    );

    uint256 public postCount;
    mapping(uint256 => BlogPost) public blogPosts;

    event BlogPostCreated(
        uint256 indexed id,
        address indexed author,
        string title,
        string body,
        string subBody,
        bool isVerified,
        string[] media,
        uint256 timestamp
    );
    event BlogPostLiked(
        uint256 indexed id,
        address indexed liker,
        uint256 likes
    );

    modifier validatePostId(uint256 postId) {
        require(postId > 0 && postId <= postCount, "Invalid post ID");
        _;
    }

    function createBlogPost(
        string memory title,
        string memory body,
        string memory subBody,
        string[] memory media
    ) external {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(body).length > 0, "Body cannot be empty");

        postCount++;
        blogPosts[postCount] = BlogPost(
            postCount,
            msg.sender,
            title,
            body,
            subBody,
            block.timestamp,
            true,
            media,
            new address[](0)
        );

        emit BlogPostCreated(
            postCount,
            msg.sender,
            title,
            body,
            subBody,
            true,
            media,
            block.timestamp
        );
    }

    function getBlogPost(
        uint256 postId
    )
        external
        view
        validatePostId(postId)
        returns (
            uint256 id,
            address author,
            string memory title,
            string memory body,
            string memory subBody,
            bool isVerified,
            string[] memory media,
            address[] memory likers,
            uint256 timestamp
        )
    {
        BlogPost storage post = blogPosts[postId];
        return (
            post.id,
            post.author,
            post.title,
            post.body,
            post.subBody,
            post.isVerified,
            post.media,
            post.likers,
            post.timestamp
        );
    }

    function listBlogPost() external view returns (BlogPost[] memory) {
        BlogPost[] memory allPosts = new BlogPost[](postCount);
        
        for (uint256 i = 0; i < postCount; i++) {
            allPosts[i] = blogPosts[i + 1];
        }
        return allPosts;
    }

    function getTotalPostCount() external view returns (uint256) {
        return postCount;
    }

    function likePost(
        uint256 postId,
        address payable author
    ) external payable validatePostId(postId) {
        uint256 minAmount = 1000000000000000; // 0.001 ether in wei

        BlogPost storage post = blogPosts[postId];

        require(post.author == author, "It's only payble to post author");
        require(msg.value >= minAmount, "Minimum amount not met");

        address liker = msg.sender;

        // Check if the user has already liked the post
        for (uint256 i = 0; i < post.likers.length; i++) {
            require(
                post.likers[i] != liker,
                "You have already liked this post"
            );
        }

        post.likers.push(liker);
        author.transfer(msg.value);
        emit BlogPostLiked(postId, liker, post.likers.length);
    }

    function getPostLikeCount(
        uint256 postId
    ) external view validatePostId(postId) returns (uint256) {
        BlogPost storage post = blogPosts[postId];
        return post.likers.length;
    }

    // Function to dislike a blog post
    function dislikePost(uint256 postId) external validatePostId(postId) {
        BlogPost storage post = blogPosts[postId];
        address disliker = msg.sender;

        // Check if the user has already disliked the post
        for (uint256 i = 0; i < post.likers.length; i++) {
            if (post.likers[i] == disliker) {
                // Remove the disliker from the likers array
                // by shifting the elements and decreasing the array length
                for (uint256 j = i; j < post.likers.length - 1; j++) {
                    post.likers[j] = post.likers[j + 1];
                }
                post.likers.pop(); // Remove the last element (duplicated)

                emit BlogPostDisliked(postId, disliker, post.likers.length);
                return; // Exit the function once the user is removed from likers
            }
        }

        revert("You have not liked this post"); // User cannot dislike if not previously liked
    }
}
