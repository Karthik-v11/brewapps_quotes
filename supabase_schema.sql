-- Quotes Table
create table quotes (
  id uuid default uuid_generate_v4() primary key,
  content text not null,
  author text not null,
  category text not null,
  created_at timestamp with time zone default now()
);

-- Profiles Table
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  username text,
  avatar_url text,
  updated_at timestamp with time zone default now()
);

-- Favorites Table
create table favorites (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  quote_id uuid references quotes on delete cascade not null,
  created_at timestamp with time zone default now(),
  unique(user_id, quote_id)
);

-- Collections Table
create table collections (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  name text not null,
  description text,
  created_at timestamp with time zone default now()
);

-- Collection_Quotes Junction Table
create table collection_quotes (
  collection_id uuid references collections on delete cascade not null,
  quote_id uuid references quotes on delete cascade not null,
  primary key (collection_id, quote_id)
);

-- Enable RLS
alter table quotes enable row level security;
alter table profiles enable row level security;
alter table favorites enable row level security;
alter table collections enable row level security;
alter table collection_quotes enable row level security;

-- Policies for quotes (Read only for all)
create policy "Quotes are viewable by everyone" on quotes
  for select using (true);

-- Policies for profiles
create policy "Users can view any profile" on profiles
  for select using (true);

create policy "Users can insert their own profile" on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update their own profile" on profiles
  for update using (auth.uid() = id);

-- Recommended: Trigger for automatic profile creation on signup
-- This handles the case where users aren't logged in immediately (email confirmation)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, avatar_url)
  values (new.id, new.raw_user_meta_data->>'username', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Policies for favorites
create policy "Users can view their own favorites" on favorites
  for select using (auth.uid() = user_id);

create policy "Users can insert their own favorites" on favorites
  for insert with check (auth.uid() = user_id);

create policy "Users can delete their own favorites" on favorites
  for delete using (auth.uid() = user_id);

-- Policies for collections
create policy "Users can view their own collections" on collections
  for select using (auth.uid() = user_id);

create policy "Users can create their own collections" on collections
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own collections" on collections
  for update using (auth.uid() = user_id);

create policy "Users can delete their own collections" on collections
  for delete using (auth.uid() = user_id);

-- Policies for collection_quotes
create policy "Users can view quotes in their collections" on collection_quotes
  for select using (
    exists (
      select 1 from collections
      where collections.id = collection_quotes.collection_id
      and collections.user_id = auth.uid()
    )
  );

create policy "Users can add quotes to their collections" on collection_quotes
  for insert with check (
    exists (
      select 1 from collections
      where collections.id = collection_id
      and collections.user_id = auth.uid()
    )
  );

create policy "Users can remove quotes from their collections" on collection_quotes
  for delete using (
    exists (
      select 1 from collections
      where collections.id = collection_id
      and collections.user_id = auth.uid()
    )
  );
