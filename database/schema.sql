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

-- 4. RLS Policies (Enforce auth.uid() scope, no anonymous public access)

-- family_members policies
CREATE POLICY "Allow authenticated read family_members" ON family_members
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow user insert own profile" ON family_members
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

CREATE POLICY "Allow user update own profile" ON family_members
    FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE POLICY "Allow user delete own profile" ON family_members
    FOR DELETE TO authenticated USING (auth.uid() = id);

-- categories policies
CREATE POLICY "Allow authenticated read categories" ON categories
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Allow authenticated insert categories" ON categories
    FOR INSERT TO authenticated WITH CHECK (true);

-- products policies
CREATE POLICY "Allow user read own products" ON products
    FOR SELECT TO authenticated USING (auth.uid() = created_by);

CREATE POLICY "Allow user insert own products" ON products
    FOR INSERT TO authenticated WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Allow user update own products" ON products
    FOR UPDATE TO authenticated USING (auth.uid() = created_by) WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Allow user delete own products" ON products
    FOR DELETE TO authenticated USING (auth.uid() = created_by);
