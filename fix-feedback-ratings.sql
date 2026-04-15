-- Fix feedback ratings from 0 to actual values
-- This updates all feedbacks with overallRating = 0 to a proper value

USE feedback_db;

-- Update existing feedbacks with invalid ratings
UPDATE feedbacks SET rating = 5 
WHERE id IN (10, 11, 12, 13, 14) AND rating = 0;

UPDATE feedbacks SET rating = 4 
WHERE id IN (15, 16, 17, 18, 19) AND rating = 0;

UPDATE feedbacks SET rating = 3 
WHERE id IN (20, 21) AND rating = 0;

-- Verify
SELECT id, product_id, product_name, user_id, overall_rating, rating FROM feedbacks LIMIT 10;
