-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Master: Roles
CREATE TABLE m_roles (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- 2. Master: Actions
CREATE TABLE m_actions (
    id SERIAL PRIMARY KEY,
    action_code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- 3. Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. User Identifiers
CREATE TABLE user_identifiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    identifier_type VARCHAR(50) NOT NULL, -- e.g., 'email', 'username', 'device_id'
    identifier_value VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255), -- Nullable for passwordless auth
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (identifier_type, identifier_value)
);

-- 5. User Details
CREATE TABLE user_details (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    email VARCHAR(255), -- Contact email, separate from auth identifier
    phone_number VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. System Settings
CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Action Logs
CREATE TABLE action_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action_id INTEGER NOT NULL REFERENCES m_actions(id),
    details JSONB, -- Using JSONB for efficient querying
    ip_address VARCHAR(45),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. User Roles (New Table for Many-to-Many relationship with validity period)
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES m_roles(id) ON DELETE CASCADE,
    start_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    end_at TIMESTAMP WITH TIME ZONE, -- Null means indefinite
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_user_identifiers_user_id ON user_identifiers(user_id);
CREATE INDEX idx_action_logs_user_id ON action_logs(user_id);
CREATE INDEX idx_action_logs_action_id ON action_logs(action_id);
CREATE INDEX idx_action_logs_created_at ON action_logs(created_at);
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX idx_user_roles_period ON user_roles(user_id, start_at, end_at);

-- Initial Data
INSERT INTO m_roles (code, name, description) VALUES
('free', 'Free Member', '通常会員'),
('plus', 'Plus Member', 'プラス会員'),
('pro', 'Pro Member', 'プロ会員'),
('admin', 'Administrator', '管理者'),
('developer', 'Developer', '開発者'),
('analyst', 'Data Analyst', 'データアナリスト'),
('maintainer', 'Maintainer', 'メンテナー'),
('support', 'Support', 'サポート');
