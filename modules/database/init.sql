-- ott_db 데이터베이스는 이미 클러스터 생성 시 자동으로 생성됨
USE ott_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    region_code ENUM('KOR', 'USA') NOT NULL,
    subscription_status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS contents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    age_rating VARCHAR(10),
    like_count INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS contents_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content_id INT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (content_id) REFERENCES contents(id)
);

CREATE TABLE IF NOT EXISTS watch_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content_id INT,
    last_played_time INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (content_id) REFERENCES contents(id)
);

CREATE TABLE IF NOT EXISTS video_assets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content_id INT,
    video_url VARCHAR(500),
    duration INT,
    FOREIGN KEY (content_id) REFERENCES contents(id)
);

-- 초기 테스트 데이터 (이미 존재하면 스킵)
INSERT IGNORE INTO users (id, email, password_hash, region_code, subscription_status) VALUES
(1, 'kim@example.kr', 'hash_pw_1', 'KOR', 'active'),
(2, 'lee@example.kr', 'hash_pw_2', 'KOR', 'inactive'),
(3, 'smith@example.com', 'hash_pw_3', 'USA', 'active'),
(4, 'john@example.com', 'hash_pw_4', 'USA', 'trial');

INSERT IGNORE INTO contents (id, title, description, age_rating, like_count) VALUES
(1, 'Squid Game', 'A mysterious survival game...', '18+', 1500),
(2, 'Stranger Things', 'Mysterious events in Hawkins...', '15+', 2300),
(3, 'The Glory', 'A story of revenge...', '18+', 1200);

INSERT IGNORE INTO watch_history (id, user_id, content_id, last_played_time) VALUES
(1, 1, 1, 1200),
(2, 3, 2, 3600);
