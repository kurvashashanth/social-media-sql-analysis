use social_media;


#q1Most Active Users (Posts + Comments)
SELECT
    u.user_id,
    u.username,
    COALESCE(p.post_count, 0) AS total_posts,
    COALESCE(c.comment_count, 0) AS total_comments,
    COALESCE(p.post_count, 0) + COALESCE(c.comment_count, 0) AS total_activity
FROM users u
LEFT JOIN (
    SELECT user_id, COUNT(*) AS post_count
    FROM posts
    GROUP BY user_id
) p ON u.user_id = p.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) AS comment_count
    FROM comments
    GROUP BY user_id
) c ON u.user_id = c.user_id
ORDER BY total_activity DESC
LIMIT 10;

#q2 Most Liked Posts and Creators
SELECT
    p.post_id,
    u.username,
    COUNT(l.like_id) AS total_likes
FROM posts p
JOIN users u
ON p.user_id = u.user_id
LEFT JOIN likes l
ON p.post_id = l.post_id
GROUP BY p.post_id, u.username
ORDER BY total_likes DESC
LIMIT 10;

#q3 Top Countries by Average Engagement
SELECT
    u.country,
    ROUND(AVG(like_count),2) AS avg_likes_per_post
FROM
(
    SELECT
        p.post_id,
        p.user_id,
        COUNT(l.like_id) AS like_count
    FROM posts p
    LEFT JOIN likes l
    ON p.post_id=l.post_id
    GROUP BY p.post_id,p.user_id
) x
JOIN users u
ON x.user_id=u.user_id
GROUP BY u.country
ORDER BY avg_likes_per_post DESC;

#q4Trending Hashtags (Used in >20 Posts)
SELECT
    h.tag_name,
    COUNT(ph.post_id) AS total_posts
FROM hashtags h
JOIN post_hashtags ph
ON h.hashtag_id=ph.hashtag_id
GROUP BY h.hashtag_id,h.tag_name
HAVING COUNT(ph.post_id)>20
ORDER BY total_posts DESC;

#q5Top Influencers (Users with Most Followers)
SELECT
    u.user_id,
    u.username,
    COUNT(f.follower_user_id) AS followers
FROM users u
LEFT JOIN followers f
ON u.user_id=f.user_id
GROUP BY u.user_id,u.username
ORDER BY followers DESC
LIMIT 10;

#q6Followers Who Never Interacted
SELECT
    DISTINCT u.user_id,
    u.username
FROM users u
JOIN followers f
ON u.user_id=f.follower_user_id
LEFT JOIN likes l
ON u.user_id=l.user_id
LEFT JOIN comments c
ON u.user_id=c.user_id
WHERE l.user_id IS NULL
AND c.user_id IS NULL;

#q7 Hashtags with Highest Engagement
SELECT
    h.tag_name,
    COUNT(DISTINCT l.like_id)+COUNT(DISTINCT c.comment_id) AS engagement
FROM hashtags h
JOIN post_hashtags ph
ON h.hashtag_id=ph.hashtag_id
LEFT JOIN likes l
ON ph.post_id=l.post_id
LEFT JOIN comments c
ON ph.post_id=c.post_id
GROUP BY h.tag_name
ORDER BY engagement DESC;

#q8 Busiest Posting Hours or Days
SELECT
    HOUR(created_at) AS posting_hour,
    COUNT(*) AS total_posts
FROM posts
GROUP BY posting_hour
ORDER BY total_posts DESC;

#q9 Inactive Users
SELECT
    u.user_id,
    u.username
FROM users u
LEFT JOIN posts p
ON u.user_id=p.user_id
LEFT JOIN likes l
ON u.user_id=l.user_id
LEFT JOIN comments c
ON u.user_id=c.user_id
WHERE p.user_id IS NULL
AND l.user_id IS NULL
AND c.user_id IS NULL;

#q10  Top Countries with Most Influencers
SELECT
    u.country,
    COUNT(*) AS influencers
FROM
(
    SELECT
        user_id,
        COUNT(follower_user_id) AS followers
    FROM followers
    GROUP BY user_id
    HAVING COUNT(follower_user_id)>=10
) f
JOIN users u
ON f.user_id=u.user_id
GROUP BY u.country
ORDER BY influencers DESC;



# BONUS CHALLENGES
#1 Engagement rate = (likes + comments) / posts
SELECT
    u.user_id,
    u.username,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    ROUND(
        (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id))
        / NULLIF(COUNT(DISTINCT p.post_id), 0),
        2
    ) AS engagement_rate
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN likes l
    ON p.post_id = l.post_id
LEFT JOIN comments c
    ON p.post_id = c.post_id
GROUP BY u.user_id, u.username
ORDER BY engagement_rate DESC;

#2Mutual followers
SELECT
    f1.user_id AS user1,
    f1.follower_user_id AS user2
FROM followers f1
JOIN followers f2
    ON f1.user_id = f2.follower_user_id
   AND f1.follower_user_id = f2.user_id
WHERE f1.user_id < f1.follower_user_id;

#3 Most used hashtags by top 5 influencers
SELECT
    h.tag_name,
    COUNT(*) AS usage_count
FROM post_hashtags ph
JOIN hashtags h
    ON ph.hashtag_id = h.hashtag_id
JOIN posts p
    ON ph.post_id = p.post_id
WHERE p.user_id IN (
    SELECT user_id
    FROM followers
    GROUP BY user_id
    ORDER BY COUNT(follower_user_id) DESC
    LIMIT 5
)
GROUP BY h.tag_name
ORDER BY usage_count DESC;

#4  Country-wise engagement leaderboard
SELECT
    u.country,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    COUNT(DISTINCT p.post_id) AS total_posts,
    (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) AS total_engagement
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN likes l
    ON p.post_id = l.post_id
LEFT JOIN comments c
    ON p.post_id = c.post_id
GROUP BY u.country
ORDER BY total_engagement DESC;




