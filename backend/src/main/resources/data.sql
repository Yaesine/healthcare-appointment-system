-- Sample data for testing
-- Note: Passwords are hashed with BCrypt (password = "password123")
INSERT INTO users (username, password, email, first_name, last_name) VALUES
('patient1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'patient1@example.com', 'John', 'Doe'),
('patient2', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'patient2@example.com', 'Jane', 'Smith');

