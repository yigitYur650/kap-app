-- DDL for Shopping List (KAP) database

-- 1. Family Members Table
CREATE TABLE IF NOT EXISTS family_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Categories Table
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Products Table
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    price NUMERIC,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    quantity NUMERIC NOT NULL DEFAULT 1.0,
    unit TEXT,
    is_bought BOOLEAN NOT NULL DEFAULT false,
    is_deleted BOOLEAN NOT NULL DEFAULT false,
    created_by UUID REFERENCES family_members(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable Row Level Security (RLS)
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies (Allow anonymous public access for development)

-- family_members policies
CREATE POLICY "Allow public read family_members" ON family_members
    FOR SELECT USING (true);

CREATE POLICY "Allow public insert family_members" ON family_members
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public update family_members" ON family_members
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow public delete family_members" ON family_members
    FOR DELETE USING (true);

-- categories policies
CREATE POLICY "Allow public read categories" ON categories
    FOR SELECT USING (true);

CREATE POLICY "Allow public insert categories" ON categories
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public update categories" ON categories
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow public delete categories" ON categories
    FOR DELETE USING (true);

-- products policies
CREATE POLICY "Allow public read products" ON products
    FOR SELECT USING (true);

CREATE POLICY "Allow public insert products" ON products
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public update products" ON products
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow public delete products" ON products
    FOR DELETE USING (true);
