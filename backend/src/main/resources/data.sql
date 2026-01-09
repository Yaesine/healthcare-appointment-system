-- Sample data for testing
-- Note: Passwords are hashed with BCrypt (password = "password123")
-- Disable foreign key checks for H2
SET REFERENTIAL_INTEGRITY FALSE;
INSERT INTO users (id, username, password, email, first_name, last_name) VALUES
(1, 'patient1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'patient1@example.com', 'John', 'Doe'),
(2, 'patient2', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'patient2@example.com', 'Jane', 'Smith');
SET REFERENTIAL_INTEGRITY TRUE;

